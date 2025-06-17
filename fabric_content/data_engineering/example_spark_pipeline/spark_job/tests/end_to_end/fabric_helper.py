"""
Helper class for interacting with Microsoft Fabric REST API and OneLake storage for end-to-end pipeline testing.
"""
import os
import tempfile
import requests
from azure.identity import ClientSecretCredential
from azure.storage.filedatalake import DataLakeServiceClient

class FabricHelper:
    def __init__(self):
        self.tenant_id = os.getenv("FABRIC_TENANT_ID")
        self.client_id = os.getenv("FABRIC_CLIENT_ID")
        self.client_secret = os.getenv("FABRIC_CLIENT_SECRET")
        self._access_token = None

    def get_access_token(self) -> str:
        """
        Get an access token for the Fabric API using the service principal.
        """
        if self._access_token is None:
            credential = ClientSecretCredential(self.tenant_id, self.client_id, self.client_secret)
            token = credential.get_token("https://api.fabric.microsoft.com/.default")
            self._access_token = token.token
        return self._access_token

    def invalidate_token(self) -> None:
        """
        Invalidate the cached access token.
        """
        self._access_token = None

    def get_auth_header(self) -> dict:
        """
        Returns the Authorization header for requests to Fabric API.
        """
        token = self.get_access_token()
        return {"Authorization": f"Bearer {token}"}

    def trigger_pipeline(self, workspace_id: str, pipeline_id: str, payload: dict = None) -> None:
        """
        Trigger a Fabric pipeline.
        """
        url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/items/{pipeline_id}/jobs/instances?jobType=Pipeline"
        headers = self.get_auth_header()
        headers["Content-Type"] = "application/json"
        default_payload = {
            "executionData": {
                "parameters": {
                    "param_waitsec": "60"
                }
            }
        }
        response = requests.post(url, headers=headers, json=payload or default_payload)
        if response.status_code not in (200, 202):
            print("❌ Error triggering pipeline:")
            print(f"Status Code: {response.status_code}")
            print(f"Response Text: {response.text}")
            print(f"Response JSON: {response.json() if response.headers.get('Content-Type') == 'application/json' else 'N/A'}")
            response.raise_for_status()

    def poll_pipeline_until_complete(self, workspace_id: str, pipeline_id: str, run_id: str = None, interval: int = 10, timeout: int = 900):
        """
        Poll the Fabric pipeline run status every `interval` seconds until it completes or times out.
        Returns (status, duration_seconds).
        If run_id is provided, will look for that run; otherwise, will poll the latest run.
        """
        import time
        url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/items/{pipeline_id}/jobs/instances?$top=1"
        headers = self.get_auth_header()
        print(f"⏳ Polling pipeline {pipeline_id} in workspace {workspace_id}...")
        start_time = time.time()
        while True:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            runs = response.json().get("value", [])
            if not runs:
                print("⚠️ No pipeline runs found.")
                return None, None
            latest_run = runs[0]
            # If run_id is specified, make sure we're polling the correct run
            if run_id and latest_run.get("id") != run_id:
                print(f"Waiting for run_id {run_id} to appear as latest...")
                time.sleep(interval)
                continue
            status = latest_run.get('status')
            duration = latest_run.get('duration') or int(time.time() - start_time)
            print(f"Status: {status}")
            if status in ["Succeeded", "Failed", "Cancelled", "Completed"]:
                return status, duration
            if time.time() - start_time > timeout:
                print("❌ Polling timed out.")
                return status, duration
            time.sleep(interval)

    def download_table_parquet_to_local(self, lakehouse_name: str, table_name: str, workspace_name: str = None) -> str:
        """
        Download the first Parquet file from the OneLake table (excluding _delta_log) to a local temp file and return the local path.
        """
        credential = ClientSecretCredential(self.tenant_id, self.client_id, self.client_secret)
        account_url = "https://onelake.dfs.fabric.microsoft.com"
        service_client = DataLakeServiceClient(account_url=account_url, credential=credential)

        file_system_client = service_client.get_file_system_client(file_system=workspace_name)
        table_path = f"{lakehouse_name}.lakehouse/Tables/{table_name}"
        directory_client = file_system_client.get_directory_client(table_path)
        paths = directory_client.get_paths()
        for path in paths:
            # Only pick Parquet files that are NOT in _delta_log
            if path.name.endswith(".parquet") and "_delta_log" not in path.name:
                file_client = file_system_client.get_file_client(path.name)
                local_temp = tempfile.NamedTemporaryFile(delete=False, suffix=".parquet")
                download = file_client.download_file()
                local_temp.write(download.readall())
                local_temp.close()
                print(f"✅ Downloaded Parquet file to {local_temp.name}")
                return local_temp.name
        raise FileNotFoundError(f"No Parquet file found in the specified table directory: {table_path}")

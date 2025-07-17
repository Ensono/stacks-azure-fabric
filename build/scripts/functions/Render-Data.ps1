function Render-Data($data) {
    $output = @()

    foreach ($key in $data.keys) {

        $prepend = ""
        if (!$data[$key].required) {
            $prepend = "# "
        }

        # get the description of the item
        if (![string]::isNullOrEmpty($data[$key].description)) {
            $description = $data[$key].description -split "`n"
            foreach ($d in $description) {
                $output += "# {0}" -f $d
            }
        }

        # ensure that True and False are correctly cased
        $value = $data[$key].value
        if ($value.tostring() -eq "True" -or $value.tostring() -eq "False") {
            $value = $value.tostring().tolower()
        }

        $output += $config[$Shell].template -f $prepend, $key, $value

        # if there is an alias set then set to the name of the variable
        if (![String]::IsNullOrEmpty($data[$key].alias)) {

            # Set the value for the alias, based on the shell or operating system
            if ($Shell -eq "bash") {
                $value = '${{{0}}}' -f $key
            }
            else {
                $value = '${{env:{0}}}' -f $key
            }

            $output += $config[$Shell].template -f $prepend, $item.alias, $value
        }
    }

    return $output
}

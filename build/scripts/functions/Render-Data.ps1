function Render-Data($data) {
    $output = @()

    foreach ($key in $data.keys) {
        $item = $data[$key]

        $prepend = ""
        if (!$item.required) {
            $prepend = "# "
        }

        # get the description of the item
        if (![string]::isNullOrEmpty($item.description)) {
            $description = $item.description -split "`n"
            foreach ($d in $description) {
                $output += "# {0}" -f $d
            }
        }



        # ensure that True and False are correctly cased
        $value = $item.value
        if ($value.tostring() -eq "True" -or $value.tostring() -eq "False") {
            $value = $value.tostring().tolower()
        }

        $output += $config[$Shell].template -f $prepend, $key, $value
    }

    return $output
}

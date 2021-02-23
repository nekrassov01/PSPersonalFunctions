Get-Variable -Exclude *Preference | Remove-Variable -ErrorAction Ignore

Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$target = Join-Path -Path (Resolve-Path -Path '..\Functions' -Relative) -ChildPath $sut
. $target

Describe 'Write-Log' {

    BeforeAll {
        $ErrorActionPreferenceOriginal = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    }

    AfterAll {
        $ErrorActionPreference = $ErrorActionPreferenceOriginal
    }

    Context '正常系' {

        It 'パラメータなし' {
            Write-Log | Should -BeTrue
        }

        It 'パラメータ指定、明示あり' {
            Write-Log -InputObject 'test' | Should -BeTrue
        }

        It 'パラメータ指定、明示なし' {
            Write-Log 'test' | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Statusを指定' {
            Write-Log -InputObject 'test' -Prefix '# ' -Separator ' | ' -Suffix ',' -Status 'Started' | Should -BeTrue
        }

        It '空のPrefix/Separator/Suffix/Statusを指定' {
            Write-Log -InputObject 'test' -Prefix '' -Separator '' -Suffix '' -Status 'Completed' | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Statusを$nullで指定' {
            Write-Log -InputObject 'test' -Prefix $null -Separator $null -Suffix $null -Status $null | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Statusを指定＋GridLine' {
            Write-Log -InputObject 'test' -Prefix '# ' -Separator ' | ' -Suffix ',' -Status 'Started' -GridLine | Should -BeTrue
        }

        It '空のPrefix/Separator/Suffix/Statusを指定＋GridLine' {
            Write-Log -InputObject 'test' -Prefix '' -Separator '' -Suffix '' -Status 'Completed' -GridLine | Should -BeTrue
        }

        It 'Prefix/Separator/Suffix/Statusを$nullで指定＋GridLine' {
            Write-Log -InputObject 'test' -Prefix $null -Separator $null -Suffix $null -Status $null -GridLine | Should -BeTrue
        }

        It '配列を渡す' {
            Write-Log -InputObject @('a', 'b', 'c') | Should -BeTrue
        }

        It 'HashTableを渡す' {
            Write-Log -InputObject (@{ a = '1'; b = '2'; c = '3' }) | Should -BeTrue
        }

        It 'PSCustomObjectを渡す' {
            Write-Log -InputObject ([PsCustomObject]@{ a = '1'; b = '2'; c = '3' }) | Should -BeTrue
        }

        It '配列の要素を渡す' {
            Write-Log -InputObject @('a', 'b', 'c')[0] | Should -BeTrue
        }

        It 'HashTableのキーを渡す' {
            Write-Log -InputObject ([ordered]@{ a = '1'; b = '2'; c = '3' }).Keys | Should -BeTrue
        }

        It 'HashTableのバリューを渡す' {
            Write-Log -InputObject ([ordered]@{ a = '1'; b = '2'; c = '3' }).Values | Should -BeTrue
        }

        It 'PSCustomObjectのプロパティを渡す' {
            Write-Log -InputObject ([PsCustomObject]@{ a = '1'; b = '2'; c = '3' }).a | Should -BeTrue
        }

        It '空の引数を渡す' {
            Write-Log -InputObject '' | Should -BeTrue
        }

        It '$nullを渡す' {
            Write-Log -InputObject $null | Should -BeTrue
        }

        It 'すべてのフォーマット系パラメータに$nullを渡す' {
            Write-Log -InputObject $null -Prefix $null -Separator $null -Suffix $null -Status $null | Should -BeTrue
        }

        It '日付フォーマットを指定する' {
            Write-Log -InputObject 'test' -DateTimeFormat 'yyyyMMddHHmmss' | Should -BeTrue
        }

        It '空の日付フォーマットを指定する' {
            Write-Log -InputObject 'test' -DateTimeFormat '' | Should -BeTrue
        }

        It '空の日付フォーマットに$nullを渡す' {
            Write-Log -InputObject 'test' -DateTimeFormat $null | Should -BeTrue
        }
    }
}

Pop-Location

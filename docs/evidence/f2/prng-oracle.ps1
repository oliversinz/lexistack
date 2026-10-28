# Independent BigInteger reference; no Dart/application methods are called.
foreach ($seed in @(1, 42, 20261028, 2147483646)) {
    $state = [System.Numerics.BigInteger]$seed
    $vector = for ($n = 0; $n -lt 8; $n++) {
        $state = ($state * 16807) % 2147483647
        $state.ToString()
    }
    Write-Output "Seed $seed vector: $($vector -join ', ')"
    $state = [System.Numerics.BigInteger]$seed
    $order = @(0..15)
    for ($i = 15; $i -gt 0; $i--) {
        $state = ($state * 16807) % 2147483647
        $j = [int]($state % ($i + 1))
        $order[$i], $order[$j] = $order[$j], $order[$i]
    }
    Write-Output "Seed $seed order: $($order -join ', '); state: $state"
}
exit 0

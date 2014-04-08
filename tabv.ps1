function sp($file1, $file2) {
    vim -o2 $file1 $file2
}

function vs($file1, $file2) {
    vim -O2 $file1 $file2
}

function Tabv($name) {
    vim -c "Tabv $name"
}

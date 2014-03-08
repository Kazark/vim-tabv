function sp($file1, $file2) {
    vim -o2 $file1 $file2
}

function vs($file1, $file2) {
    vim -O2 $file1 $file2
}

function Tabv($name) {
    vs inc/$name.hpp src/$name.cpp
}

function Tabcxxv($name) {
    vs inc/$name.hpp src/$name.cpp
}

function Tabjsv($name) {
    vs unittests/$name.src src/$name.spec.js
}

alias vs='vim -O2'
alias sp='vim -o2'
function Tabv {
    vs inc/$1.hpp src/$1.cpp
    #vim --cmd "e src/$1.cpp | vs inc/$1.hpp | sp unittest/$1Tests.cpp"
}

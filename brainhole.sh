#!/bin/bash
# Yet another brainhole.
# WARN: The functions does not check for empty vars, and declaring references
#       may cause NULL pointer reference segfaults.
# TODO: Check for set variables before applying ns refs/aliases.
# Note: Bash treats a::b as a valid identifier for funcnames but not for varnames.
shopt -s expand_aliases
_namespace_a_funcs='lorem ipsum '
_namespace_a_vars='foo bar '
#a::lorem(){ echo -n lorem\ ; }
#a::ipsum(){ echo ipsum; }
a__lorem(){ echo -n lorem\ ; }
a__ipsum(){ echo ipsum; }
a__foo=fool a__bar=fibre1
a=ah b=bash
wat(){ echo wat; }
debug(){ ((DEBUG)) && echo -e DEBUG: "$@"; }
import_ns(){
        declare -n fun=_namespace_$1_funcs var=_namespace_$1_vars;
        local f;
        #for f in $fun; do alias $f="$1::$f"; done;
        for f in $fun; do alias $f="$1__$f"; done;
        for f in $var; do declare -gn $f="a__$f"; done;
}
escape_ns(){
        declare -n fun=_namespace_$1_funcs var=_namespace_$1_vars;
        unalias $fun;
        unset $var;
}
append_ns(){
        debug append_ns "$@"
        declare -n fun=_namespace_$1_funcs var=_namespace_$1_vars;
        local i tfun tvar ns="$1";
        shift;
        for i; do
                if tfun=$(declare -f $i); then
                        debug gotfun $i
                        #eval "${tfun/$i/$ns::$i}";      # first occurrence has to be func declare.
                        eval "${tfun/$i/$ns__$i}";      # first occurrence has to be func declare.
                        fun+="$i ";
                fi
                if tvar=$(declare -p $i 2>/dev/null); then
                        debug gotvar $i
                        tvar="${tvar/$i=/${ns}__$i=}";  # first foo= occurrence must be varname.
                        eval "${tvar/declare -- /}"
                        var+="$i ";
                fi
                unset $i
        done
        debug nsfun     $fun
        debug nsvar     $var
}
echo Importing namespace.;
import_ns a;
lorem;
ipsum;
echo $foo $bar;
echo Set foo to p.;
foo=p;
echo \$foo=$foo \$a__foo=$a__foo;
echo Exiting namespace.;
escape_ns a;
echo Expect command not found.;
lorem;
DEBUG=1
echo Appending new stuffs to namespace a.
append_ns a   a b wat
echo Re-importing a.
import_ns a
echo vars a and b.
echo $a $b
echo test func.
wat







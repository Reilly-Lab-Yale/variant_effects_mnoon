for cell_type in HepG2 K562 SKNSH
do
    case $cell_type in
        HepG2) color="252,167,58" ;;
        SKNSH) color="233,29,35" ;;
        K562)  color="24,158,146" ;;
    esac
    sed -e "s/CT/${cell_type}/g" \
        -e "s/color: #[0-9a-fA-F]\{6\};/color: rgb(${color});/" \
        CT.html > ${cell_type}.html
done
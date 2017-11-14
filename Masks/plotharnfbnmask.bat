btogtx mask.harnfbn.30.b
echo calling temp.bat
chmod 755 temp.bat
./temp.bat
echo makecpt
makecpt -Crainbow -T-0.5/1/0.1  -Z > temp.cpt
echo grdgradient
grdgradient temp.grd -N4.8 -A90 -M -Gtempi.grd
echo grdview
grdview temp.grd -T -JM9.5i -B5/5:."HARN/FBN Mask:" -Ctemp.cpt -K > mask.harnfbn.30.ps
echo pscoast
pscoast -W1p,white -Df -R -JM -W -N1/1p,white -N2/1p,white -A1200 -O >> mask.harnfbn.30.ps
echo ps2raster
ps2raster mask.harnfbn.30.ps -Tj -P -A
rm -f temp.cpt
rm -f tempi.grd
rm -f temp.grd
#rm -f temp.bat
rm -f temp.gtx

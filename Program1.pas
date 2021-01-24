uses graphabc;

function MessageBox(h: integer; m,c: string; t: integer): integer; 
external 'User32.dll' name 'MessageBox';

type gobj1=class
name1:string;
x1:real;
y1:real;
props1:=new list<KeyValuePair<string,string>>();
constructor(a:string;b,c:real);
begin
name1:=a;
x1:=b;
y1:=c;
end;
function tostring1(a:integer):string;
begin
Result:='<object id="'+a+'" name="'+name1+'" x="'+x1+'" y="'+y1+'"';
if props1.Count=0 then
Result+='/>'
else
begin
Result+='>'#10'<properties>'#10;
foreach var pr in props1 do
Result+='<property name="'+pr.Key+'" value="'+pr.Value+'"/>'#10;
Result+='</properties>'#10'</object>';
end;
end;
end;

var
// util
keys1:=new boolean[256];
need_redraw1:=false;
clsn1:=new list<array of Point>();
gobjs1:=new list<gobj1>();
// map util
map1:='';
tiles1:=new Picture(1,1);
lay_bg1:array[,] of byte;
lay_fg1:array[,] of byte;
map_width1:=0;
map_height1:=0;
tile_size1:=0;
sprites1:=new dictionary<string,picture>();
// graphics
back1:picture;
backday1:=true;
off_x1:=450;
off_y1:=300;
zoom1:=0.0;
tls1:array of picture;
showpalette1:=false;
palette1:Picture;
draw_idx1:=1;
draw_in_bg1:=false;
collision_mode1:=false;
inspector_mode1:=false;
inspector_id1:=-1;
popup_text1:='';
popup_visib1:=0.0;

function inrange1(a,b,c:integer):boolean;
begin
if b<c then
Result:=(a>=b) and (a<=c)
else
Result:=(a>=c) and (a<=b);
end;

function betw1(a:string;b:string;c:string):array of string;
begin
var l1:=new list<string>();
repeat
var i1:=a.IndexOf(b);
if i1=-1 then
break;
var i2:=a.IndexOf(c,i1+b.Length);
if i2=-1 then
break;
l1.Add(a.Substring(i1+b.Length,i2-i1-b.Length));
a:=a.Substring(i2+c.Length);
until false;
Result:=l1.ToArray;
end;

function rbetw1(a:string;b:string;c:string;d:array of string):string;
begin
var wi1:=0;
var si1:=0;
while (si1<a.Length) and (wi1<d.Length) do
begin
var i1:=a.IndexOf(b,si1);
if i1=-1 then
break;
var i2:=a.IndexOf(c,i1+b.Length);
if i2=-1 then
break;
a:=a.Substring(0,i1+b.Length)+d[wi1]+a.Substring(i2);
wi1+=1;
si1:=i2+c.Length;
end;
Result:=a;
end;

function setsize1(a:picture;w,h:integer):picture;
begin
var bmp1:=new system.drawing.bitmap(a.bmp,w,h);
result:=new Picture(w,h);
var gr1:=System.Drawing.Graphics.FromImage(Result.bmp);
gr1.DrawImage(bmp1,0,0);
end;

function trim1(a:string):string;
begin
var s1:=1;
var e1:=a.Length;
while (s1<=a.Length) and ((a[s1]=' ') or (a[s1]=#9) or (a[s1]=#10)) do
s1+=1;
while (e1>s1) and ((a[e1]=' ') or (a[e1]=#9) or (a[e1]=#10)) do
e1-=1;
Result:=a.Substring(s1-1,e1-s1+1);
end;

function gen_sky1(x,y:integer;fr1,to1:color):picture;
begin
result:=new Picture(x,y);
for var y1:=0 to y-1 do
begin
SetPenColor(rgb(fr1.R+(to1.R-fr1.R)*y1 div y,fr1.G+(to1.G-fr1.G)*y1 div y,fr1.B+(to1.B-fr1.B)*y1 div y));
result.line(0,y1,x,y1);
end;
end;

procedure fatalerror1(a:string);
begin
SetWindowSize(1,1);
MessageBox(0,a,'Error',16);
Halt(1);
end;

function decodelayout1(a:string;b:integer):array[,] of byte;
begin
var ba1:=System.Convert.FromBase64CharArray(a.ToCharArray,0,a.Length);
var m1:=new System.IO.MemoryStream(ba1);
var m2:=new System.IO.MemoryStream();
var gz1:=new System.IO.Compression.GZipStream(m1,system.IO.Compression.CompressionMode.Decompress);
var buf1:=new byte[4096];
while true do
begin
var rd1:=gz1.Read(buf1,0,4096);
if rd1=0 then
break;
m2.Write(buf1,0,rd1);
end;
ba1:=m2.ToArray;
Result:=new byte[ba1.Length div 4 div b,b];
for var i:=0 to ba1.Length div 4-1 do
Result[i div b,i mod b]:=ba1[i*4];
end;

function explode1(a:picture;b:integer):array of Picture;
begin
Result:=new Picture[(a.Width div b)*(a.Height div b)];
for var y:=0 to a.Height div b-1 do
for var x:=0 to a.Width div b-1 do
begin
var cp1:=new Picture(b,b);
cp1.CopyRect(System.Drawing.Rectangle.Create(0,0,b,b),a,System.Drawing.Rectangle.Create(x*2+x*b,y*2+y*b,b,b));
result[x+y*(a.Width div b)]:=cp1;
end;
end;

procedure keydown1(k:integer);
begin
if k=VK_I then
begin
inspector_mode1:=not inspector_mode1;
need_redraw1:=true;
end;
if k=VK_C then
begin
collision_mode1:=not collision_mode1;
need_redraw1:=true;
end;
if k=VK_P then
begin
showpalette1:=not showpalette1;
need_redraw1:=true;
end;
if k=VK_L then
begin
draw_in_bg1:=not draw_in_bg1;
need_redraw1:=true;
end;
keys1[k]:=true;
end;

procedure keyup1(k:integer);
begin
keys1[k]:=false;
end;

procedure draw_layout1(a:array[,] of byte);
begin
var xs1:=Max(0,off_x1-450-tile_size1);
var ys1:=Max(0,off_y1-300-tile_size1);
var xe1:=Min(map_width1*tile_size1-tile_size1,xs1+900+tile_size1);
var ye1:=Min(map_height1*tile_size1-tile_size1,ys1+900+tile_size1);
for var y:=ys1 div tile_size1 to ye1 div tile_size1 do
for var x:=xs1 div tile_size1 to xe1 div tile_size1 do
begin
var idx1:=a[y,x]-1;
if idx1<0 then
continue;
tls1[idx1].Draw(x*tile_size1-off_x1+450,y*tile_size1-off_y1+300);
//if idx1<>0 then
//TextOut(x*tile_size1-off_x1+450,y*tile_size1-off_y1+300,x+'x'+y+#10+idx1);
end;
end;

function getcolls1(a:string):list<array of point>;
begin
Result:=new List<array of Point>();
var objs1:=betw1(a,'<object','/object>');
for var i:=0 to objs1.Length-1 do
begin
var c1:=objs1[i];
var xo1:=StrToFloat(betw1(c1,'x="','"')[0]);
var yo1:=StrToFloat(betw1(c1,'y="','"')[0]);
var pts1:=betw1(c1,'points="','"')[0].Split(' ');
var add1:=new point[pts1.Length];
for var i1:=0 to pts1.Length-1 do
add1[i1]:=new point(Round(StrToFloat(pts1[i1].Split(',')[0])+xo1),Round(StrToFloat(pts1[i1].Split(',')[1])+yo1));
Result.Add(add1);
end;
end;

procedure draw_colls1();
begin
SetPenColor(clBlue);
SetPenWidth(3);
SetBrushColor(clTransparent);
foreach var cl in clsn1 do
begin
var cl1:=new point[cl.Length];
for var i:=0 to cl.Length-1 do
cl1[i]:=new Point(cl[i].X-off_x1+450,cl[i].Y-off_y1+300);
if cl1.Length>1 then
Polygon(cl1)
else
drawcircle(cl1[0].x,cl1[0].Y,3);
end;
end;

function replaceall1(a,b,c:string):string;
begin
var si1:=0;
repeat
var si2:=a.IndexOf(b,si1);
if si2=-1 then
break;
a:=a.Substring(0,si2)+c+a.Substring(si2+b.Length);
si1:=si2+c.Length;
until false;
Result:=a;
end;

function read_objects1(a:string):list<gobj1>;
begin
var onesec1:=betw1(a,'<object','/>');
for var i:=0 to onesec1.Length-1 do
if not onesec1[i].Contains('<properties') then
onesec1[i]+='</object>';
a:=rbetw1(a,'<object','/>',onesec1);
a:=replaceall1(a,'</object>/>','</object>');
result:=new List<gobj1>();
var objs1:=betw1(a,'<object','/object>');
foreach var co in objs1 do
begin
var no1:=new gobj1(betw1(co,'name="','"')[0],strtofloat(betw1(co,'x="','"')[0]),strtofloat(betw1(co,'y="','"')[0]));
foreach var pr in betw1(co,'<property','/>') do
no1.props1.Add(new KeyValuePair<string,string>(betw1(pr,'name="','"')[0],betw1(pr,'value="','"')[0]));
Result.Add(no1);
end;
end;

function pairinlist1(a:list<KeyValuePair<string,string>>;b:string):integer;
begin
for var i:=0 to a.Count-1 do
if a[i].Key=b then
begin
Result:=i;
exit;
end;
Result:=-1;
end;

procedure draw_objs1();
begin
SetBrushColor(ARGB(50,0,0,0));
SetFontColor(clRed);
SetPenWidth(2);
SetPenColor(clRed);
foreach var obj in gobjs1 do
begin
var x1:=Round(obj.x1-off_x1+450);
var y1:=Round(obj.y1-off_y1+300);
if (not inrange1(x1,-50,950)) or (not inrange1(y1,-50,650)) then
continue;
var tw1:=TextWidth(obj.name1);
var th1:=TextHeight(obj.name1);
var si1:=pairinlist1(obj.props1,'sprite');
if (si1>-1) and (sprites1.ContainsKey(obj.props1[si1].Value)) then
begin
var cp1:=sprites1[obj.props1[si1].Value];
cp1.Draw(x1-cp1.Width div 2,y1-cp1.Height div 2);
end;
Rectangle(x1-tw1 div 2-5,y1-th1 div 2-5,x1+tw1 div 2+5,y1+th1 div 2+5);
DrawTextCentered(x1,y1,obj.name1);
end;
end;

procedure draw_grid1(a:integer);
begin
SetPenColor(clGray);
SetPenWidth(1);
for var x:=0 to WindowWidth div a do
line(x*a-(off_x1-450) mod a,0,x*a-(off_x1-450) mod a,WindowHeight);
for var y:=0 to WindowHeight div a do
line(0,y*a-(off_y1-300) mod a,WindowWidth,y*a-(off_y1-300) mod a);
end;

function prepare_palette1():picture;
begin
SetPenColor(clYellow);
SetBrushColor(clTransparent);
Result:=new Picture(495,495);
Result.Clear(ARGB(200,0,0,0));
Result.CopyRect(System.Drawing.Rectangle.Create(0,0,495,495),setsize1(tiles1,495,495),System.Drawing.Rectangle.Create(0,0,495,495));
for var y:=0 to 14 do
for var x:=0 to 14 do
Result.Rectangle(x*33,y*33,x*33+33,y*33+33);
end;

function point_idx1(a:point):KeyValuePair<integer,integer>;
begin
for var i:=0 to clsn1.Count-1 do
for var i1:=0 to clsn1[i].Length-1 do
if sqr(a.X-clsn1[i][i1].X)+Sqr(a.Y-clsn1[i][i1].Y)<Sqr(10) then
begin
Result:=new KeyValuePair<integer,integer>(i,i1);
exit;
end;
Result:=new KeyValuePair<integer,integer>(-1,-1);
end;

function object_idx1(a:point):integer;
begin
for var i:=0 to gobjs1.Count-1 do
begin
var obj:=gobjs1[i];
var tw1:=(obj.name1).Length*9;
var th1:=18;
if inrange1(a.x,Round(obj.x1)-tw1 div 2-5,Round(obj.x1)+tw1 div 2+5) and inrange1(a.y,Round(obj.y1)-th1 div 2-5,Round(obj.y1)+th1 div 2+5) then
begin
Result:=i;
exit;
end;
end;
Result:=-1;
end;

procedure down1(x,y,b:integer);
begin
if inspector_mode1 then
begin
var oi1:=object_idx1(new point(x+off_x1-450,y+off_y1-300));
if oi1=-1 then
begin
gobjs1.Add(new gobj1('Empty',x+off_x1-450,y+off_y1-300));
end
else
begin
inspector_id1:=oi1;
end;
need_redraw1:=true;
exit;
end;
if collision_mode1 then
begin
var pi1:=point_idx1(new point(x+off_x1-450,y+off_y1-300));
if b=1 then
begin
if pi1.Key=-1 then
begin
var l1:=clsn1[clsn1.Count-1].ToList;
l1.Add(new point(x+off_x1-450,y+off_y1-300));
clsn1[clsn1.Count-1]:=l1.ToArray;
end
else
begin
var l1:=clsn1[pi1.Key].ToList;
l1.RemoveAt(pi1.Value);
if l1.Count=0 then
clsn1.RemoveAt(pi1.Key)
else
clsn1[pi1.Key]:=l1.ToArray;
end;
end
else if b=2 then
begin
if pi1.Key=-1 then
begin
clsn1.Add(new point[](new point(x+off_x1-450,y+off_y1-300)));
end
else
begin
clsn1.RemoveAt(pi1.Key);
end;
end;
need_redraw1:=true;
exit;
end;
if showpalette1 and (x<495) and (y<495) then
begin
draw_idx1:=(x div 33)+(y div 33*15)+1;
showpalette1:=false;
need_redraw1:=true;
exit;
end;
if (showpalette1) and (b=1) then
begin
if draw_in_bg1 then
draw_idx1:=lay_bg1[(off_y1+y-300) div tile_size1,(off_x1+x-450) div tile_size1]
else
draw_idx1:=lay_fg1[(off_y1+y-300) div tile_size1,(off_x1+x-450) div tile_size1];
need_redraw1:=true;
exit;
end;
end;

procedure move1(x,y,b:integer);
begin
if keys1[VK_ShiftKey] and inspector_mode1 then
begin
var oi1:=object_idx1(new point(x+off_x1-450,y+off_y1-300));
if oi1>-1 then
begin
gobjs1[oi1].x1:=x+off_x1-450;
gobjs1[oi1].y1:=y+off_y1-300;
need_redraw1:=true;
end;
exit;
end;
if (b<>1) or (inspector_mode1) then
exit;
if draw_in_bg1 then
lay_bg1[(off_y1+y-300) div tile_size1,(off_x1+x-450) div tile_size1]:=draw_idx1
else
lay_fg1[(off_y1+y-300) div tile_size1,(off_x1+x-450) div tile_size1]:=draw_idx1;
need_redraw1:=true;
end;

function resize_matrix1(a:array[,] of byte;w,h,m:integer):array[,] of byte;
begin
var clx1:=a.GetUpperBound(1)+1;
var cly1:=a.GetUpperBound(0)+1;
var ox1:=m div 10;
var oy1:=m mod 10;
case ox1 of
1: ox1:=0;
2: ox1:=w div 2-clx1 div 2;
3: ox1:=w-clx1;
end;
case oy1 of
1: oy1:=0;
2: oy1:=h div 2-cly1 div 2;
3: oy1:=h-cly1;
end;
Result:=new byte[h,w];
for var y:=0 to cly1-1 do
for var x:=0 to clx1-1 do
if inrange1(y+oy1,0,h-1) and inrange1(x+ox1,0,w-1) then
Result[y+oy1,x+ox1]:=a[y,x];
ox1*=tile_size1 div 2;
oy1*=tile_size1 div 2;
foreach var c in clsn1 do
for var i:=0 to c.Length-1 do
c[i]:=new point(c[i].x+ox1,c[i].y+oy1);
foreach var o in gobjs1 do
begin
o.x1+=ox1;
o.y1+=oy1;
end;
end;

procedure reload_sprites1(a:picture;b:string);
begin
b:=b.Substring(b.IndexOf('<key>frames</key>')+20);
var ar1:=betw1(b,'<key>','</dict>');
sprites1.Clear();
foreach var s in ar1 do
begin
if not s.Contains('frame') then
continue;
var crds1:=betw1(s,'{{','}}')[0];
crds1:=replaceall1(crds1,'{','');
crds1:=replaceall1(crds1,'}','');
var crds2:=crds1.Split(',');
var x1:=StrToInt(crds2[0]);
var y1:=StrToInt(crds2[1]);
var w1:=StrToInt(crds2[2]);
var h1:=StrToInt(crds2[3]);
var np1:=new Picture(w1,h1);
np1.CopyRect(System.Drawing.Rectangle.Create(0,0,w1,h1),a,System.Drawing.Rectangle.Create(x1,y1,w1,h1));
sprites1.Add(s.Substring(0,s.IndexOf('<')-4),np1);
end;
end;

function getbackcolor1(a:picture):color;
begin
var r1:=0;
var g1:=0;
var b1:=0;
var c1:=a.Width div 10*a.Height div 10;
for var y:=0 to a.Height div 10-1 do
for var x:=0 to a.Width div 10-1 do
begin
var p1:=a.GetPixel(x*10,y*10);
r1+=p1.r;
g1+=p1.g;
b1+=p1.b;
end;
Result:=RGB(255-r1 div c1,255-g1 div c1,255-b1 div c1);
end;

function propresize1(a,b:point):point;
begin
if b.x/a.x>b.y/a.y then
Result:=new Point(a.x,Round(b.y/b.x*a.x))
else
Result:=new Point(Round(b.x/b.y*a.y),a.y);
end;

procedure textout1(x,y,r:integer;s:string);
begin
SetCoordinateOrigin(x,y);
SetCoordinateAngle(r);
DrawTextCentered(0,0,0,0,s);
SetCoordinateOrigin(0,0);
SetCoordinateAngle(0);
end;

function isnumber1(a:string):boolean;
begin
Result:=false;
for var i:=1 to a.Length do
if not a[i].IsDigit then
exit;
Result:=a.Length<>0;
end;

procedure remove_sprite1(a:string);
begin
var sprts1:=ReadAllText('menuTexture.plist');
var fnd1:=sprts1.IndexOf('<key>'+a+'.png</key>');
if fnd1=-1 then
exit;
var fnd2:=sprts1.IndexOf('</dict>',fnd1);
if fnd2=-1 then
exit;
sprts1:=sprts1.Substring(0,fnd1)+sprts1.Substring(fnd2+7);
WriteAllText('menuTexture.plist',sprts1);
end;

procedure insert_sprite1(a:string;x1,y1,x2,y2:integer);
begin
var sprts1:=ReadAllText('menuTexture.plist');
var idx1:=sprts1.IndexOf('<key>frames</key>');
idx1:=sprts1.IndexOf('<dict>',idx1)+6;
var obj1:=
#10#9'<key>'+a+'.png</key>'
#10#9'<dict>'
#10#9'<key>frame</key>'
#10#9'<string>{{'+x1+','+y1+'},{'+(x2-x1)+','+(y2-y1)+'}}</string>'
#10#9'<key>offset</key>'
#10#9'<string>{0,0}</string>'
#10#9'<key>rotated</key>'
#10#9'<false/>'
#10#9'<key>sourceColorRect</key>'
#10#9'<string>{{0,0},{'+(x2-x1)+','+(y2-y1)+'}}</string>'
#10#9'<key>sourceSize</key>'
#10#9'<string>{'+(x2-x1)+','+(y2-y1)+'}</string>'
#10#9'</dict>';
sprts1:=sprts1.Substring(0,idx1)+obj1+sprts1.Substring(idx1);
WriteAllText('menuTexture.plist',sprts1);
end;

function clsn_tostr1(a:integer;b:array of point):string;
begin
var a1:=new point[b.Length];
System.Array.ConstrainedCopy(b,0,a1,0,a1.Length);
b:=a1;
var bx1:=0;
var by1:=0;
var cl1:='';
foreach var p in b do
begin
bx1+=Round(p.X);
by1+=Round(p.Y);
end;
bx1:=bx1 div b.Length;
by1:=by1 div b.Length;
foreach var p in b do
cl1+=Round(p.x-bx1)+','+Round(p.y-by1)+' ';
cl1:=cl1.Substring(0,cl1.Length-1);
Result:=
'<object id="'+a+'" name="co_poly" x="'+bx1+'" y="'+by1+'">'#10
'<polygon points="'+cl1+'"/>'#10
'</object>';
end;

procedure enumerate_objects1();
begin
var names1:=new list<string>();
var nums1:=new list<integer>();
foreach var n in gobjs1 do
begin
var name1:=n.name1;
var num1:='';
while (name1.Length>0) and (char.IsDigit(name1[name1.Length])) do
begin
num1:=name1[name1.Length]+num1;
name1:=name1.Substring(0,name1.Length-1);
end;
if num1.Length=0 then
continue;
if not names1.Contains(name1) then
begin
names1.Add(name1);
nums1.Add(StrToInt('1'+num1));
end
else
begin
var nn1:=StrToInt('1'+num1);
nums1[names1.IndexOf(name1)]:=Min(nums1[names1.IndexOf(name1)],nn1);
end;
end;
for var i:=0 to gobjs1.Count-1 do
begin
var name1:=gobjs1[i].name1;
while (name1.Length>0) and (char.IsDigit(name1[name1.Length])) do
name1:=name1.Substring(0,name1.Length-1);
if not names1.Contains(name1) then
continue;
gobjs1[i].name1:=name1+nums1[names1.IndexOf(name1)].ToString.Substring(1);
nums1[names1.IndexOf(name1)]+=1;
end;
end;

function encodelayout1(a:array[,] of byte):string;
begin
var ba1:=new byte[(a.GetUpperBound(0)+1)*(a.GetUpperBound(1)+1)*4];
var idx1:=0;
for var y:=0 to a.GetUpperBound(0) do
for var x:=0 to a.GetUpperBound(1) do
begin
ba1[idx1]:=a[y,x];
idx1+=4;
end;
var m1:=new System.IO.MemoryStream(ba1);
var m2:=new System.IO.MemoryStream();
var gz1:=new System.IO.Compression.GZipStream(m2,system.IO.Compression.CompressionMode.Compress);
m1.CopyTo(gz1);
gz1.Dispose();
ba1:=m2.ToArray;
Result:=System.Convert.ToBase64String(ba1);
end;

procedure save_to_file1(a:string);
begin
enumerate_objects1();
//Writeln(clsn_tostr1(2,clsn1[3]));
var nmap1:=map1;
nmap1:=rbetw1(nmap1,'width="','"',new string[](map_width1+''));
nmap1:=rbetw1(nmap1,'height="','"',new string[](map_height1+''));
var lays1:=betw1(nmap1,'<layer','</layer>');
for var i:=0 to lays1.Length-1 do
begin
lays1[i]:=rbetw1(lays1[i],'width="','"',new string[](map_width1+''));
lays1[i]:=rbetw1(lays1[i],'height="','"',new string[](map_height1+''));
end;
lays1[0]:=rbetw1(lays1[0],'<data encoding="base64" compression="gzip">','</data>',new string[](encodelayout1(lay_bg1)));
lays1[1]:=rbetw1(lays1[1],'<data encoding="base64" compression="gzip">','</data>',new string[](encodelayout1(lay_fg1)));
nmap1:=rbetw1(nmap1,'<layer','</layer>',lays1);
var id1:=1;
var objss1:=''+#10;
foreach var o in gobjs1 do
begin
objss1+=o.tostring1(id1)+#10;
id1+=1;
end;
nmap1:=rbetw1(nmap1,'<objectgroup name="objects">','</objectgroup>',new string[](objss1));
var clsns1:=''+#10;
foreach var o in clsn1 do
begin
clsns1+=clsn_tostr1(id1,o)+#10;
id1+=1;
end;
nmap1:=rbetw1(nmap1,'<objectgroup name="collision">','</objectgroup>',new string[](clsns1));
WriteAllText(a,nmap1);
map1:=nmap1;
end;

label end1;

begin
SetFontSize(12);
SetFontColor(clred);
SetWindowSize(900,600);
back1:=gen_sky1(WindowWidth,WindowHeight,RGB(0,162,232),RGB(153,217,234));
SetWindowCaption('Mini Militia Map Editor by 64BitWorm');
Window.IsFixedSize:=true;
CenterWindow();
LockDrawing();
SetBrushColor(clTransparent);
SetGraphABCIO();
while true do
begin
gen_sky1(WindowWidth,WindowHeight,rgb(255,255,255),rgb(100,100,100)).Draw(0,0);
var maps1:=system.io.directory.EnumerateDirectories(GetCurrentDir).Tolist;
var str1:='';
for var i:=0 to maps1.Count-1 do
str1+=maps1[i].substring(maps1[i].lastindexof('\')+1)+#10;
if FileExists('map.tmx') then
str1+=#10+'Date of the last map change: '+System.IO.File.GetLastWriteTime('map.tmx').ToString+#10
else
str1+=#10'WARNING! there is no map loaded in the workspace, do it with "import" command'#10;
TextOut(10,10,'Map manager'#10'     export [name]  -  save map to library'#10'     import [name]  -  load map into workspace'#10'     delete [name]  -  exclude map from library'#10'     hit ENTER (without command input) to edit map in workspace'#10#10'Maps in library:'#10+str1);
Redraw();
var in1:=ReadString.Split(' ');
case in1[0] of
'': break;
'export':
begin
MkDir(GetCurrentDir+'\'+in1[1]);
System.IO.File.Copy(GetCurrentDir+'\map.tmx',GetCurrentDir+'\'+in1[1]+'\map.tmx',true);
System.IO.File.Copy(GetCurrentDir+'\tiles.png',GetCurrentDir+'\'+in1[1]+'\tiles.png',true);
end;
'import':
begin
System.IO.File.Copy(GetCurrentDir+'\'+in1[1]+'\map.tmx',GetCurrentDir+'\map.tmx',true);
System.IO.File.Copy(GetCurrentDir+'\'+in1[1]+'\tiles.png',GetCurrentDir+'\tiles.png',true);
end;
'delete':
begin
System.IO.File.Delete(GetCurrentDir+'\'+in1[1]+'\map.tmx');
System.IO.File.Delete(GetCurrentDir+'\'+in1[1]+'\tiles.png');
RmDir(GetCurrentDir+'\'+in1[1]+'\');
end;
end;
end;
SetConsoleIO();
gen_sky1(WindowWidth,WindowHeight,rgb(255,255,255),rgb(150,150,150)).Draw(0,0);
TextOut(15,15,'Loading...');
Redraw();
if not FileExists('map.tmx') then
fatalerror1('There is no "map.tmx" file (place it in app folder)');
if not FileExists('tiles.png') then
fatalerror1('There is no "tiles.png" file (place it in app folder)');
map1:=ReadAllText('map.tmx');
tiles1:=new Picture('tiles.png');
var ti1:=new Picture(tiles1.Width-2,tiles1.Height-2);
ti1.CopyRect(System.Drawing.Rectangle.Create(0,0,tiles1.Width-2,tiles1.Height-2),tiles1,System.Drawing.Rectangle.Create(1,1,tiles1.Width-2,tiles1.Height-2));
tiles1:=ti1;
palette1:=prepare_palette1();
if tiles1.Width<>tiles1.Height then
fatalerror1('Wrong texture file');
if (map1.IndexOf('tilewidth="')=-1) then
fatalerror1('There is no information about tile size');
tile_size1:=StrToInt(betw1(map1,'tilewidth="','"')[0]);
var ar1:=betw1(map1,'<layer','/layer>');
if ar1.Length<>2 then
fatalerror1('Wrong map file');
if ar1[0].IndexOf('name="tilebg"')=-1 then
Swap(ar1[0],ar1[1]);
if (ar1[0].IndexOf('name="tilebg"')=-1) or (ar1[1].IndexOf('name="tile"')=-1) then
fatalerror1('Map file does not contain the required sections');
if (ar1[0].IndexOf('width="')=-1) or (ar1[0].IndexOf('height="')=-1) then
fatalerror1('There is no information about map size');
map_width1:=strtoint(betw1(ar1[0],'width="','"')[0]);
map_height1:=StrToInt(betw1(ar1[0],'height="','"')[0]);
var bg_str1:=trim1(betw1(ar1[0],'<data encoding="base64" compression="gzip">','</data>')[0]);
var fg_str1:=trim1(betw1(ar1[1],'<data encoding="base64" compression="gzip">','</data>')[0]);
lay_bg1:=decodelayout1(bg_str1,map_width1);
lay_fg1:=decodelayout1(fg_str1,map_width1);
tls1:=explode1(tiles1,tile_size1);
if betw1(map1,'<objectgroup name="collision">','</objectgroup>').Length<>1 then
fatalerror1('Wrong collision section');
clsn1:=getcolls1(betw1(map1,'<objectgroup name="collision">','</objectgroup>')[0]);
if betw1(map1,'<objectgroup name="objects">','</objectgroup>').Length<>1 then
fatalerror1('Wrong objects section');
gobjs1:=read_objects1(betw1(map1,'<objectgroup name="objects">','</objectgroup>')[0]);
if not FileExists('menuTexture.png') then
fatalerror1('There is no "menuTexture.png" file (apk/assets/sd/menuTexture.png)');
if not FileExists('menuTexture.plist') then
fatalerror1('There is no "menuTexture.plist" file (apk/assets/sd/menuTexture.plist)');
reload_sprites1(new Picture('menuTexture.png'),ReadAllText('menuTexture.plist'));
OnKeyDown+=keydown1;
OnKeyUp+=keyup1;
OnMouseDown+=down1;
OnMouseMove+=move1;
gen_sky1(WindowWidth,WindowHeight,RGB(0,0,40),RGB(0,64,128)).Draw(0,0);
DrawTextCentered(450,300,'Help:'#10'WASD - camera position'#10'P - show/hide palette'#10'L - change draw layout'#10'I - insert new object'#10'C - manage collisions'#10'R - resize map'#10'M - manage sprites'#10'T - save to tmx file'#10#10'21.01.2021 :)');
Redraw();
while true do
begin
if keys1[vk_T] then
begin
save_to_file1('map.tmx');
popup_text1:='Map Saved';
popup_visib1:=1.0;
need_redraw1:=true;
Sleep(300);
end;
if keys1[VK_M] then
begin
SetGraphABCIO;
var page1:=0;
var border1:=new point(100,100);
while true do
begin
gen_sky1(WindowWidth,WindowHeight,rgb(0,40,0),rgb(0,100,40)).Draw(0,0);
var si1:=page1*40;
var cx1:=0;
var cy1:=0;
var ks1:=sprites1.Keys.ToArray();
SetFontColor(clLime);
for var i:=si1 to min(si1+39,sprites1.Count-1) do
begin
var cx2:=10+cx1*110;
var cy2:=10+cy1*110;
var ci1:=sprites1[ks1[i]];
var ns1:=propresize1(border1,new point(ci1.Width,ci1.Height));
ci1:=setsize1(ci1,ns1.x,ns1.y);
//SetBrushColor(getbackcolor1(ci1));
ci1.Draw(cx2+(border1.x div 2-ns1.X div 2),cy2+(border1.y div 2-ns1.y div 2));
Rectangle(cx2,cy2,cx2+border1.x,cy2+border1.y);
textout1(cx2+border1.x div 2,cy2+border1.y div 2,45,ks1[i]);
cx1+=1;
if cx1=8 then
begin
cx1:=0;
cy1+=1;
end;
end;
TextOut(10,553,'Page: '+page1+'/'+sprites1.Count div 40+' Enter page or: "remove [name]" to delete picture, "insert [name] [x1] [y1] [x2] [y2]" to insert frame, "find [name]"');
Redraw;
var in1:=ReadString().Split(' ');
if isnumber1(in1[0]) then
begin
page1:=strtoint(in1[0]);
end
else case in1[0] of
'': break;
'find':
begin
page1:=sprites1.Count div 40+1;
for var i:=0 to ks1.Length-1 do
if ks1[i].IndexOf(in1[1])>-1 then
begin
page1:=i div 40;
break;
end;
end;
'remove':
begin
remove_sprite1(in1[1]);
reload_sprites1(new Picture('menuTexture.png'),ReadAllText('menuTexture.plist'));
end;
'insert':
begin
insert_sprite1(in1[1],StrToInt(in1[2]),StrToInt(in1[3]),StrToInt(in1[4]),StrToInt(in1[5]));
reload_sprites1(new Picture('menuTexture.png'),ReadAllText('menuTexture.plist'));
end;
end;
end;
SetConsoleIO;
need_redraw1:=true;
keys1[VK_M]:=false;
end;
if inspector_id1>-1 then
begin
SetGraphABCIO();
SetBrushColor(clTransparent);
while true do
begin
gen_sky1(WindowWidth,WindowHeight,RGB(0,0,30),RGB(0,0,70)).Draw(0,0);
var prp1:=''#10;
for var i:=0 to gobjs1[inspector_id1].props1.Count-1 do
prp1+=gobjs1[inspector_id1].props1[i].Key+' = '+gobjs1[inspector_id1].props1[i].Value+#10;
TextOut(10,10,'Object Editor'#10#10'Name: '+gobjs1[inspector_id1].name1+#10'X pos: '+gobjs1[inspector_id1].x1+#10'Y pos: '+gobjs1[inspector_id1].y1+#10'Props: '+prp1+#10'Command list:'#10'   name [newname]  -  rename object'#10'   addprop [name] [value]  -  add new property'#10'   setprop [name] [value]  -  set property value'#10'   delprop [index]  -  delete property by index'#10'   delete  -  delete current object          totop  -  make it first in draw order'#10'   exit  -  close object editor        light  -  change lighting (day/night)'#10'General commands:'#10'   delete_all_collisions'#10'   delete_all_objects'#10'   clear_background'#10'   clear_foreground'#10#10'Objects:'#10'   spritefg - sprite on foreground (image name from "sprite" property)'#10'   spritebg - sprite on background (image name from "sprite" property)'#10'   wp_p_00 - weapon spawner (weapon list in "weapon" property, for example "machete,ak47")'#10'   sp_p_00 - player spawner (no properties)      ctf_sp_1 - ctf spawner (no properties)'#10'   fp_b_1 - flag stations (in "sprite" property must be "flagStationOrange" or "flagStationBlue")     fp_1  -  flag spawner'#10#10'Full weapon list: m93ba, flame, m14, ak47, tavor, xm8, minigun, gasnade, fragnade, empnade, machete, riot, smaw, rg6,'#10'phasr, shotgun, m16, sawgun, tec9, mp5, uzi, proxynade, emp, healthpack, boosttank');
Redraw();
var in1:=ReadString().Split(' ');
case in1[0] of
'exit','': begin inspector_id1:=-1; break; end;
'xpos': gobjs1[inspector_id1].x1:=strtofloat(in1[1]);
'ypos': gobjs1[inspector_id1].y1:=strtofloat(in1[1]);
'addprop': gobjs1[inspector_id1].props1.Add(new keyvaluepair<string,string>(in1[1],in1[2]));
'setprop': gobjs1[inspector_id1].props1[pairinlist1(gobjs1[inspector_id1].props1,in1[1])]:=new KeyValuePair<string,string>(in1[1],in1[2]);
'delprop': gobjs1[inspector_id1].props1.RemoveAt(StrToInt(in1[1]));
'delete': begin gobjs1.RemoveAt(inspector_id1); inspector_id1:=-1; break; end;
'name': gobjs1[inspector_id1].name1:=in1[1];
'delete_all_collisions': clsn1.Clear();
'delete_all_objects': begin gobjs1.Clear(); inspector_id1:=-1; break; end;
'clear_background':
begin
for var y:=0 to map_height1-1 do
for var x:=0 to map_width1-1 do
lay_bg1[y,x]:=0;
end;
'clear_foreground':
begin
for var y:=0 to map_height1-1 do
for var x:=0 to map_width1-1 do
lay_fg1[y,x]:=0;
end;
'light':
begin
backday1:=not backday1;
if backday1 then
back1:=gen_sky1(WindowWidth,WindowHeight,RGB(0,162,232),RGB(153,217,234))
else
back1:=gen_sky1(WindowWidth,WindowHeight,RGB(0,0,0),RGB(0,0,40));
end;
'totop':
begin
var t1:=gobjs1[0];
gobjs1[0]:=gobjs1[inspector_id1];
gobjs1[inspector_id1]:=t1;
inspector_id1:=0;
end;
end;
end;
end1:
SetConsoleIO();
end;
if keys1[VK_R] then
begin
SetGraphABCIO();
SetBrushColor(argb(200,0,0,0));
Rectangle(0,0,900,600);
SetBrushColor(clBlack);
try
TextOut(10,10,'Enter new map WIDTH: (now is '+map_width1+')          ');
Redraw();
map_width1:=ReadInteger();
TextOut(10,10,'Enter new map HEIGHT: (now is '+map_height1+')          ');
Redraw();
map_height1:=ReadInteger();
TextOut(10,10,'Enter resize mode:                    '#10'There is 3 align modes (1 - start, 2 - center, 3 - end)'#10'first enter alignment on X and then on Y'#10'for example, to align X and Y to the center, enter 22');
Redraw();
var mode1:=ReadInteger();
SetConsoleIO();
lay_bg1:=resize_matrix1(lay_bg1,map_width1,map_height1,mode1);
lay_fg1:=resize_matrix1(lay_fg1,map_width1,map_height1,mode1);
except
end;
keys1[VK_R]:=false;
need_redraw1:=true;
Sleep(200);
end;
if keys1[VK_W] then
begin off_y1-=15; need_redraw1:=true; end;
if keys1[VK_S] then
begin off_y1+=15; need_redraw1:=true; end;
if keys1[VK_A] then
begin off_x1-=15; need_redraw1:=true; end;
if keys1[VK_D] then
begin off_x1+=15; need_redraw1:=true; end;
if keys1[VK_E] then
begin zoom1+=0.01; need_redraw1:=true; end;
if keys1[VK_Q] then
begin zoom1-=0.01; need_redraw1:=true; end;
if (not need_redraw1) and (popup_visib1<=0) then
begin
Sleep(25);
continue;
end;
need_redraw1:=false;
var t1:=Milliseconds;
back1.Draw(0,0);
draw_layout1(lay_bg1);
draw_layout1(lay_fg1);
draw_colls1();
draw_grid1(tile_size1);
draw_objs1();
if showpalette1 then
begin
palette1.Draw(0,0);
SetBrushColor(argb(200,0,0,0));
textout(533,33,'Draw on '+(draw_in_bg1 ? 'background':'foreground')+#10#10+'X offset: '+off_x1+#10+'Y offset: '+off_y1+#10+'X size: '+map_width1*tile_size1+#10+'Y size: '+map_height1*tile_size1+#10+'tile size: '+tile_size1+#10+'colliders: '+clsn1.Count+#10+'objects: '+gobjs1.Count);
var cx1:=(draw_idx1-1) mod 15;
var cy1:=(draw_idx1-1) div 15;
drawRectangle(cx1*33,cy1*33,cx1*33+33,cy1*33+33);
end;
if collision_mode1 then
TextOut(10,10,'Collision Editor'#10'Left click on empty space to add point to last collider'#10'Left click on point to exclude it from collider'#10'Right click on point to delete whole collider'#10'Right click on empty space to create new collider'#10'You need to draw collider clockwise'#10'Point radius: 10px');
if inspector_mode1 then
TextOut(10,10,'Object Editor'#10'Left click on object to edit it'#10'Left click on empty space to create new object'#10'Shift + mouse moving to move object on screen');
SetPenColor(clred);
DrawRectangle(450-off_x1,300-off_y1,450-off_x1+map_width1*tile_size1,300-off_y1+map_height1*tile_size1);
if popup_visib1>0 then
begin
var fs1:=FontSize;
SetFontSize(128);
SetFontColor(aRGB(Trunc(Min(1,popup_visib1)*255),255,0,0));
DrawTextCentered(450,300,popup_text1);
SetFontSize(fs1);
popup_visib1-=0.02;
end;
Redraw();
Sleep(Max(0,20-(Milliseconds-t1)));
end;
end.

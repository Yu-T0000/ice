import processing.serial.*;
import ddf.minim.*;
Minim minim;
AudioSample sound,magic,magic2;
AudioPlayer bgm;
Serial myPort;


int posX = 500;
int B,a,b,c,d,la,lb,num,skyloop,posr,posl= 0;
int i,Ani,skyani,T=1;
int W,W2=2;
int box = 200;//降らせる雪の量
float X,Y,Tmp;
boolean left, right, shift,A,Z;  //向き判定, 移動制御,アクションのキー制御
boolean meltA,meltB,C,N,H,K;//雪だるま溶かすか木を溶かすか, 温度判定Cool Nomal Hot,モード判定
boolean up,L = true;    //背景画像の制御
boolean down,R = false; 
PImage sky,field,snow,snowman,tree,snowmanm,treem,light,player;     //画像素材
float [] x = new float[box];     //雪用の配列
float [] y = new float[box];
float [] s = new float[box];
int xs=130;
int x2=-100;
int deg,Timer;


void setup(){
  
//printArray(Serial.list());  //シリアルポート確認用

myPort = new Serial(this,Serial.list()[2],9600);    //Aruduinoを接続してるポートに
size(840,560);
background(0);
stroke(255);
textSize(20);
frameRate(60);
field = loadImage("field.png");
snow = loadImage("snow.png");
light = loadImage("light.png");

for(int i = 0;i<box;i++){  //雪の初期位置とサイズ
x[i]=random(width); 
y[i]=-10-random(5500);
s[i]=random(5,10);
}
//ここからbgmと効果音
minim = new Minim(this);
sound = minim.loadSample("音１.wav");  //足音
magic = minim.loadSample("氷魔法で凍結.mp3");
magic2 = minim.loadSample("キラッ2.mp3");
bgm = minim.loadFile("maou_bgm_healing04.mp3");
bgm.loop();
}


void draw(){
  
  //シリアル通信処理
  
  if(millis()-Timer>50){
  Timer=millis();
  byte[]inBuf = new byte[5];    //byte配列5つ arduino側のoutBuf[]と揃える
  if(myPort.available()==5){  //受信数チェック
  myPort.readBytes(inBuf);
  if(inBuf[0]=='s'&&inBuf[4]=='e'){  //確認用ダミーデータチェック
    Tmp = (inBuf[1]<<8)+(inBuf[2]&0xff);
    Tmp/=100.0;  //温度
    if(inBuf[3]==0){K=true;}
    if(inBuf[3]==1){K=false;}  //モード変更
    
    //センサ追加時はここに処理追加
    
   }
  else{//データがなんか違う
  while(myPort.available()>0)myPort.read();//クリア
  println("x");
  }
  }
  else if (myPort.available()>5){//データが多い
    println(myPort.available());
  while(myPort.available()>0)myPort.read();//クリア
  }
  byte[] outBuf = new byte[1];
  outBuf[0] =  's';
  myPort.write(outBuf);
  }
  
  //シリアル通信処理ここまで
  
  
  //温度判定
  
  float low = 17.5; 
  float high = 21.5;  
  if(Tmp<=low){C=true;N=false;H=false;}  //モード変更 ひんやり
  if(low<Tmp&&Tmp<high){C=false;N=true;H=false;}  //ノーマル
  if(Tmp>=high){C=false;N=false;H=true;}  //あったか
  
  //温度判定ここまで
  
  
  //移動制御
  
if(right){        //→キー押してる間右移動
  if(posX<=650){
    posr=25;  //キャラクター移動速度(右方向)
    posX = posX+posr;
  }
  //キャラクターの位置が650以上の時は背景とオブジェクトの方を左にズラす
  if(posX>=650){
    posr=0;
    posl=-25;  //オブジェクトの移動速度
    skyloop-=20; //背景の移動速度

//！遠景の方が遅く動いて見える！

}

}
if(left){       //←キー押してる間左移動
 if(posX>=50){
    posr=-25;
posX = posX+posr;
  }
  //キャラクターの位置が50以下の時は背景の方を左にズラす
  if(posX<=50){
  posr=0;
  posl=25;
skyloop+=20;
}
}
if(right==false&&left==false||right==true&&left==true){posl=0;}

  //移動制御ここまで
  
  
  //背景ループ処理
  
  sky();
  
    if(skyloop<-1660){skyloop=0;}
  if(skyloop>0){skyloop=-1660;}
  
    //背景ループ処理ここまで
  
image(sky,skyloop,0);  //空画像表示
image(field,0,50);  //地面画像表示


snow();  //雪降らす


if(A){  //キャラクターの位置に雪だるまを作る
snowman(posX);
}
if(meltA){  //雪だるま溶かす
meltA();
}


//アニメーション処理

//1~10：立ち(呼吸),11~14：歩き, 15~26：アクション
Ani+=1;  //次の画像へ
if(Ani==11){Ani=1;}  //立ち
if(Ani==15){Ani=11;}  //歩き
if(Ani==26){Ani=1;}  //アクション
if((left||right)&&(Ani<11||Ani>14)){Ani=11;}  //移動キー顔されてる間歩きアニメーションをループ
if((left==false&&right==false)&&(Ani>11&Ani<15)){Ani=10;}  //キー入力がなければ呼吸モーションに

//println(Ani);  //ページ送りチェック
Anime(Ani);

//アニメーション処理ここまで



if(Z){  //キャラクターの位置に木を生やす
ice1(posX);
}
if(meltB){  //木を溶かす
meltB();
}


image(field,0,60);  //前面に地面画像をもう一枚表示してぼやっとした雪っぽさを出す


//画面上テキスト類
text("←→ : Move",100,100);
if(K){text("tree",100,130);}
else{text("snowman",100,130);}
if(C){text("Z : Action",100,190);}
  else if(H){text("X : Action",100,190);}
    else{text("Warm or cool sensor",100,190);}
text(Tmp,100,160);
//画面上テキスト類ここまで

}  //draw終わり


//キー操作処理
void keyPressed() {   
    if (keyCode == RIGHT){
    R = true;
    L = false; 
     //向き判定
    right = true;
    // キー長押し判定
}
    if (keyCode == LEFT){
      R = false;
      L = true;
      left = true;
    }
    if (keyCode == SHIFT) shift = true;
   if(C){
     if(K){
     if(key == 'z') {Z= false;Ani=16;}}
     
  else{ if(key == 'z') {A= false;Ani=16;}}
    
  }
    if(H){
     if(K){ if(T==1&&key == 'x'&&lb==1) {Z=false;meltB=false;Ani=16;}}
    else{if(T==1&&key == 'x'&&la==1) {A=false;meltA=false;Ani=16;}}
  
}
}


void keyReleased() {   
    if (keyCode == RIGHT) right = false;
    if (keyCode == LEFT) left = false;
    if (keyCode == SHIFT) {shift = false;deg=3;}
   if(C) {
   if(K){if(key == 'z') {Z= true;}}
   else{if(key == 'z') {A= true;}}
    }
    if(H){
    if(K){if(T==1&&key == 'x'&&lb==1)  {meltB=true;if(c>=10){c=0;}if(d>=6){d=0;};
  }}else{
    if(T==1&&key == 'x'&&la==1) {meltA=true;if(a>=3){a=0;}if(b>=3){b=0;}
    }
  }
    }
}


/*
オブジェクトの出現位置にプレイヤーキャラの座標を使うとキー入力時一緒になって動いてしまうため
プレイヤーの位置によって左、真ん中、右のどこから生えるか判定する
*/


void snowman(int X){ //雪だるま
     xs+=posl;
        if(a==0){if(640<=X||(495<X&&X<645&&R)){W=2;} //右側
    if((145<X&&X<435&&R)||(405<X&&X<645&&L)){W=1;}//真ん中
    if(145>=X||(X<325&&L)){W=0;}//左側
   }
   if(W==0){ if(a==0){snowman=  loadImage("snowman1.png");}
    if(a==1){snowman=  loadImage("snowman2.png");}
    if(a==2){snowman=  loadImage("snowman3.png");}
    if(a>=3){snowman=  loadImage("snowman4.png");}
   }
      if(W==1){ if(a==0){snowman=  loadImage("snowman1.png");}
    if(a==1){snowman=  loadImage("snowman2.png");}
    if(a==2){snowman=  loadImage("snowman3.png");}
    if(a>=3){snowman=  loadImage("snowman6.png");}
   }
      if(W==2){ if(a==0){snowman=  loadImage("snowman1.png");}
    if(a==1){snowman=  loadImage("snowman2.png");}
    if(a==2){snowman=  loadImage("snowman3.png");}
    if(a>=3){snowman=  loadImage("snowman7.png");}
   }
    
    image(snowman,xs+W*180,300,200,200);
    a+=1;
    if(posX-xs-W*180<150&&posX-xs-W*180>-150){  //プレイヤーとオブジェクトの位置関係チェック
      la=1;  //それなりに近かったら消せるよ
    }
    else{la=0;}  //遠いので消えないよ
    }
    
    void meltA(){
    if(b==0){snowmanm=  loadImage("snowman3.png");}
    if(b==1){snowmanm=  loadImage("snowman2.png");}
    if(b==2){snowmanm=  loadImage("snowman1.png");}
    if(b==3){snowmanm=  loadImage("snowman5.png");xs=130;}
     image(snowmanm,xs+W*180,300,200,200);
    b+=1;
    
    }
    
    void ice1(int X){ //氷の木1
    x2+=posl;
   if(c==0){if(640<=X||(495<X&&X<645&&R)){W2=1;} //右側
    if((145<X&&X<435&&R)||(405<X&&X<645&&L)){W2=2;}//真ん中
    if(145>=X||(X<325&&L)){W2=3;}//左側
   }
    
   if(W2==3){
   if(c==0){tree=  loadImage("tree11.png");}
    if(c==1){tree=  loadImage("tree10.png");}
    if(c==2){tree=  loadImage("tree9.png");}
    if(c==3){tree=  loadImage("tree8.png");}
    if(c==4){tree=  loadImage("tree7.png");}
    if(c==5){tree=  loadImage("tree6.png");}
    if(c==6){tree=  loadImage("tree5.png");}
    if(c==7){tree=  loadImage("tree4.png");}
    if(c==8){tree=  loadImage("tree3.png");}
    if(c==9){tree=  loadImage("tree2.png");}
    if(c>=10){tree=  loadImage("tree1.png");}
   }
   
    if(W2==2){
   if(c==0){tree=  loadImage("treeB11.png");}
    if(c==1){tree=  loadImage("treeB10.png");}
    if(c==2){tree=  loadImage("treeB9.png");}
    if(c==3){tree=  loadImage("treeB8.png");}
    if(c==4){tree=  loadImage("treeB7.png");}
    if(c==5){tree=  loadImage("treeB6.png");}
    if(c==6){tree=  loadImage("treeB5.png");}
    if(c==7){tree=  loadImage("treeB4.png");}
    if(c==8){tree=  loadImage("treeB3.png");}
    if(c==9){tree=  loadImage("treeB2.png");}
    if(c>=10){tree=  loadImage("treeB1.png");}
   }
   
     if(W2==1){ if(c==0){tree=  loadImage("treeA11.png");}
    if(c==1){tree=  loadImage("treeA10.png");}
    if(c==2){tree=  loadImage("treeA9.png");}
    if(c==3){tree=  loadImage("treeA8.png");}
    if(c==4){tree=  loadImage("treeA7.png");}
    if(c==5){tree=  loadImage("treeA6.png");}
    if(c==6){tree=  loadImage("treeA5.png");}
    if(c==7){tree=  loadImage("treeA4.png");}
    if(c==8){tree=  loadImage("treeA3.png");}
    if(c==9){tree=  loadImage("treeA2.png");}
    if(c>=10){tree=  loadImage("treeA1.png");}
   }
   
    image(tree,x2+100*(3-W2),0,940,530);
    c+=1;
    if(posX-(x2+100*(3-W2)+940/4*(4-W2))<150&&posX-(x2+100*(3-W2)+940/4*(4-W2))>-150){
      lb=1;
    }
    else{lb=0;}
    
    }
    
    void meltB(){
      
  if(W2==3){ if(d==0){treem=  loadImage("melt1.png");}
    if(d==1){treem=  loadImage("melt2.png");}
    if(d==2){treem=  loadImage("melt3.png");}
    if(d==3){treem=  loadImage("melt4.png");}
    if(d==4){treem=  loadImage("melt5.png");}
    if(d==5){treem=  loadImage("melt6.png");x2=-100;}}
    
      if(W2==2){ if(d==0){treem=  loadImage("meltB1.png");}
    if(d==1){treem=  loadImage("meltB2.png");}
    if(d==2){treem=  loadImage("meltB3.png");}
    if(d==3){treem=  loadImage("meltB4.png");}
    if(d==4){treem=  loadImage("meltB5.png");}
    if(d==5){treem=  loadImage("meltB6.png");x2=-100;}}
    
   if(W2==1){ if(d==0){treem=  loadImage("meltA1.png");}
    if(d==1){treem=  loadImage("meltA2.png");}
    if(d==2){treem=  loadImage("meltA3.png");}
    if(d==3){treem=  loadImage("meltA4.png");}
    if(d==4){treem=  loadImage("meltA5.png");}
    if(d==5){treem=  loadImage("melt6.png");x2=-100;}
  }
     image(treem,x2+100*(3-W2),0,940,530);
    d+=1;
    }
    
      void sky(){
         if(up){num=1;}
    if(down){num=-1;}
    skyani += num;
    if(skyani<10&&down==false){up=true;}
    if(skyani==13&&up){down=true;up=false;}
    if(skyani<13&&up==false){down=true;}
    if(skyani==-3){down=false;up=true;}
    if(skyani<=1){sky =  loadImage("sky1.jpg");}
    if(skyani==2){sky =  loadImage("sky2.jpg");}
    if(skyani==3){sky =  loadImage("sky3.jpg");}
    if(skyani==4){sky =  loadImage("sky4.jpg");}
    if(skyani==5){sky =  loadImage("sky5.jpg");}
    if(skyani==6){sky =  loadImage("sky6.jpg");}
    if(skyani==7){sky =  loadImage("sky7.jpg");}
    if(skyani==8){sky =  loadImage("sky8.jpg");}
    if(skyani==9){sky =  loadImage("sky9.jpg");}
    if(skyani>=10){sky =  loadImage("sky10.jpg");}
    }
    

void snow(){    
  for(int i = 0;i<box;i++){
x[i] = x[i]+random(-noise(millis()*0.001)*7,noise(millis()*0.001)*7);
if(C){y[i] = y[i]+10;    //ひんやり状態だと雪降る
image(snow,x[i],y[i],s[i],s[i]);
if(y[i]>height-100){
y[i]=-800-random(5500);
}
}
if(N){}
if(H){y[i] = y[i]-10;     //あったか状態だと光舞う
image(light,x[i],y[i],s[i]+5,s[i]+5);
if(y[i]<-10){
y[i]=400+random(5500);
                   }
             }
        }
    }

    
    void Anime(int x){
    
    if(N){if(L){
    if(x<=5){player=  loadImage("SLd_0000.png");} //左向き立ち
    if(x==6){player=  loadImage("SLd_0001.png");}
    if(x==7){player=  loadImage("SLd_0002.png");}
    if(x==8){player=  loadImage("SLd_0003.png");}
    if(x==9){player=  loadImage("SLd_0004.png");}
    if(x==10){player=  loadImage("SLd_0005.png");}
     if(x==11){player=  loadImage("WLd_0000.png");} //左向き歩き
    if(x==12){player=  loadImage("WLd_0001.png");}
    if(x==13){player=  loadImage("WLd_0002.png");}
    if(x==14){player=  loadImage("WLd_0003.png");}
    }
    if(R){
    if(x<=5){player=  loadImage("SRd_0000.png");} //右向き立ち
    if(x==6){player=  loadImage("SRd_0001.png");}
    if(x==7){player=  loadImage("SRd_0002.png");}
    if(x==8){player=  loadImage("SRd_0003.png");}
    if(x==9){player=  loadImage("SRd_0004.png");}
    if(x==10){player=  loadImage("SRd_0005.png");}
    if(x==11){player=  loadImage("WRd_0000.png");} //右向き歩き
    if(x==12){player=  loadImage("WRd_0001.png");}
    if(x==13){player=  loadImage("WRd_0002.png");}
    if(x==14){player=  loadImage("WRd_0003.png");}
    }
    }
      if(H)  {
        if(L){
    if(x<=5){player=  loadImage("SLh_0001.png");} //左向き立ち
    if(x==6){player=  loadImage("SLh_0001.png");}
    if(x==7){player=  loadImage("SLh_0002.png");}
    if(x==8){player=  loadImage("SLh_0003.png");}
    if(x==9){player=  loadImage("SLh_0004.png");}
    if(x==10){player=  loadImage("SLh_0005.png");}
     if(x==11){player=  loadImage("WLh_0000.png");} //左向き歩き
    if(x==12){player=  loadImage("WLh_0001.png");}
    if(x==13){player=  loadImage("WLh_0002.png");}
    if(x==14){player=  loadImage("WLh_0003.png");}
    if(x==15){player=  loadImage("ALh_0000.png");}  //アクション
    if(x==16){player=  loadImage("ALh_0001.png");}
    if(x==17){player=  loadImage("ALh_0002.png");}
    if(x==18){player=  loadImage("ALh_0003.png");}
    if(x==19){player=  loadImage("ALh_0004.png");}
    if(x==20){player=  loadImage("ALh_0005.png");}
    if(x==22){player=  loadImage("ALh_0006.png");}
    if(x==23){player=  loadImage("ALh_0007.png");}
    if(x==24){player=  loadImage("ALh_0008.png");}
    if(x==25){player=  loadImage("ALh_0009.png");}
    if(x==26){player=  loadImage("ALh_00010.png");}
    }
    if(R){
    if(x<=5){player=  loadImage("SRh_0001.png");} //右向き立ち
    if(x==6){player=  loadImage("SRh_0001.png");}
    if(x==7){player=  loadImage("SRh_0002.png");}
    if(x==8){player=  loadImage("SRh_0003.png");}
    if(x==9){player=  loadImage("SRh_0004.png");}
    if(x==10){player=  loadImage("SRh_0005.png");}
    if(x==11){player=  loadImage("WRh_0000.png");} //右向き歩き
    if(x==12){player=  loadImage("WRh_0001.png");}
    if(x==13){player=  loadImage("WRh_0002.png");}
    if(x==14){player=  loadImage("WRh_0003.png");}
     if(x==15){player=  loadImage("ARh_0000.png");}   //アクション
    if(x==16){player=  loadImage("ARh_0001.png");}
    if(x==17){player=  loadImage("ARh_0002.png");}
    if(x==18){player=  loadImage("ARh_0003.png");}
    if(x==19){player=  loadImage("ARh_0004.png");}
    if(x==20){player=  loadImage("ARh_0005.png");}
    if(x==22){player=  loadImage("ARh_0006.png");}
    if(x==23){player=  loadImage("ARh_0007.png");}
    if(x==24){player=  loadImage("ARh_0008.png");}
    if(x==25){player=  loadImage("ARh_0009.png");}
    if(x==26){player=  loadImage("ARh_00010.png");}
    }
    }
      if(C){if(L){
    if(x<=5){player=  loadImage("SLc_0001.png");} //左向き立ち
    if(x==6){player=  loadImage("SLc_0001.png");}
    if(x==7){player=  loadImage("SLc_0002.png");}
    if(x==8){player=  loadImage("SLc_0003.png");}
    if(x==9){player=  loadImage("SLc_0004.png");}
    if(x==10){player=  loadImage("SLc_0005.png");}
     if(x==11){player=  loadImage("WLc_0000.png");} //左向き歩き
    if(x==12){player=  loadImage("WLc_0001.png");}
    if(x==13){player=  loadImage("WLc_0002.png");}
    if(x==14){player=  loadImage("WLc_0003.png");}
    if(x==15){player=  loadImage("ALc_0000.png");}   //アクション
    if(x==16){player=  loadImage("ALc_0001.png");}
    if(x==17){player=  loadImage("ALc_0002.png");}
    if(x==18){player=  loadImage("ALc_0003.png");}
    if(x==19){player=  loadImage("ALc_0004.png");}
    if(x==20){player=  loadImage("ALc_0005.png");}
    if(x==22){player=  loadImage("ALc_0006.png");}
    if(x==23){player=  loadImage("ALc_0007.png");}
    if(x==24){player=  loadImage("ALc_0008.png");}
    if(x==25){player=  loadImage("ALc_0009.png");}
    if(x==26){player=  loadImage("ALc_00010.png");}
    }
    if(R){
    if(x<=5){player=  loadImage("SRc_0001.png");} //右向き立ち
    if(x==6){player=  loadImage("SRc_0001.png");}
    if(x==7){player=  loadImage("SRc_0002.png");}
    if(x==8){player=  loadImage("SRc_0003.png");}
    if(x==9){player=  loadImage("SRc_0004.png");}
    if(x==10){player=  loadImage("SRc_0005.png");}
    if(x==11){player=  loadImage("WRc_0000.png");} //右向き歩き
    if(x==12){player=  loadImage("WRc_0001.png");}
    if(x==13){player=  loadImage("WRc_0002.png");}
    if(x==14){player=  loadImage("WRc_0003.png");}
     if(x==15){player=  loadImage("ARc_0000.png");}   //アクション
    if(x==16){player=  loadImage("ARc_0001.png");}
    if(x==17){player=  loadImage("ARc_0002.png");}
    if(x==18){player=  loadImage("ARc_0003.png");}
    if(x==19){player=  loadImage("ARc_0004.png");}
    if(x==20){player=  loadImage("ARc_0005.png");}
    if(x==22){player=  loadImage("ARc_0006.png");}
    if(x==23){player=  loadImage("ARc_0007.png");}
    if(x==24){player=  loadImage("ARc_0008.png");}
    if(x==25){player=  loadImage("ARc_0009.png");}
    if(x==26){player=  loadImage("ARc_00010.png");}
    }
    }
    if(x==13){sound.trigger();}
    if(C && x==17){magic.trigger();}
    if(H && x==17){magic2.trigger();}
image(player,posX,210,200,278);
    }

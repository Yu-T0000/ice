const int pin = A0;
//センサ追加時はここでピン指定
float temp,TMP,mode;
int E;

void setup() {
  
Serial.begin(9600);
  
}

void loop() {
  
  //温度センサ
  temp = ((analogRead(pin)/1024.0)*5.0-0.5)*100;//センサーの値を温度に変換
  TMP=temp*100;//整数情報にして小数点以下も送る

  //半固定抵抗器 
  mode = analogRead(A2)/127;  //1以上or1以下に分ける
  if(mode>=1){E = 1;}
  if(mode<1){E = 0;}


  //センサ追加時はここに処理
  
  
if(Serial.available()==1){  //1バイトのデータを受信
  byte inBuf[1];//配列一個 受信
  Serial.readBytes(inBuf,1);//ポートの文字列一個をinBufに入れる
  if(inBuf[0]=='s'){//文字sを受信したら
    
    byte outBuf[5];//配列5個 センサー追加時は増やす
    
    outBuf[0] = 's';
    outBuf[1] = (int16_t)(TMP)>>8;//温度上位8it
    outBuf[2] = (int16_t)(TMP)&0xFF;//温度下位8bit
    outBuf[3] = E;//モード 0or1
    //追加時はここに
    outBuf[4] = 'e';
    
    Serial.write(outBuf,5);//outBufの中身を送信
    
          }
    else{
      while(Serial.available()>0)Serial.read();//バッファを空に
      }
    }

if(Serial.available()>1){
   while(Serial.available()>0)Serial.read();
  } 
  }

  

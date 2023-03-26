const int pin = A0;
float temp,TMP;

void setup() {
  
Serial.begin(9600);
  
}

void loop() {

  temp = ((analogRead(pin)/1024.0)*5.0-0.5)*100;
  TMP=temp*100;

if(Serial.available()==1){  //1バイトのデータを受信
  byte inBuf[1];//配列一個
  Serial.readBytes(inBuf,1);//ポートの文字列一個をinBufに入れる
  if(inBuf[0]=='s'){
    byte outBuf[4];
    outBuf[0] = 's';
    outBuf[1] = (int16_t)(TMP)>>8;//上位
    outBuf[2] = (int16_t)(TMP)&0xFF;//下位
    outBuf[3] = 'e';
    Serial.write(outBuf,4);
    }
    else{
      while(Serial.available()>0)Serial.read();//バッファを空に
      }
}
if(Serial.available()>1){
   while(Serial.available()>0)Serial.read();
  } 
  }

  

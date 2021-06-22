/* 
* ENTREGABLE 2 - SECO
*
* Javier López Iniesta Díaz del Campo
* Fernando García Gutiérrez
*
*/

#include <DueTimer.h>

/* CONSTANTES */ 
#define MAX_VOLTAGE 12 // 12 V
#define MODELING_PERIOD 1200 // 1200 ms
#define FREQUENCY 20000 // 20000 Hz = 20 KHz
#define FREQUENCY_MCK 84000000 // Frecuencia reloj arduino due (84 MHz)
#define SAMPLE_PERIOD 1000 // 1000 us = 1 ms
#define PULSES_REVOLUTION 3591.84 // Reductora -> 75:1 ; CPR = 48 ; 75*48 = 3600
#define K_P 100 
#define TAO_D 0.05
#define TAO_I 5

/* PINES */ 
// Enable
const int enable = 2;   
// Pines para control de interrupciones (lectura del ENCODER)
const int port_channelA = 3;    
const int port_channelB = 7;  
// Pines del PWM Hardware
const int PWM_out1 = 35;    
const int PWM_out2 = 37; 

/* VARIABLES */ 
float VOLTAGE = 1; // Modeling [V]
float angle = TWO_PI; // angle que queremos que se mueva el motor [rad]
float error = 0;
float last_error = 0;
float derivative_error = 0;
float integral_error = 0;
float U = 0;
float duty_cycle = 0;
int pulses_counter = 0;
int timer_counter = 0; 
int* buffer_modeling; //  Array para guardar las posiciones del motor recogidas durante el Modeling
int* buffer_driver; //  Array para guardar las posiciones del motor recogidas durante cualquiera de los driveres implementados
bool screen_print = false;
bool initial_state = false;


void setup() {

  delay(1000);

  Serial.begin(115200); // velocidad en baudios

  pinMode(enable, OUTPUT);
  pinMode(port_channelA,INPUT);  
  pinMode(port_channelB,INPUT);

  pinMode(PWM_out1, OUTPUT);
  pinMode(PWM_out2, OUTPUT);

  digitalWrite(enable, HIGH); 
  
  attachInterrupt(digitalPinToInterrupt(port_channelA), encoder_channelA_ISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(port_channelB), encoder_channelB_ISR, CHANGE);

  buffer_modeling = (int*)malloc(sizeof(int)* MODELING_PERIOD +1);
  buffer_driver = (int*)malloc(sizeof(int)* 7000);

  configure_PWM(0); // Inicialmente el motor esta parado
  
  Serial.println("Time  Pulses");
 
  Timer3.attachInterrupt(EngineModeling).start(SAMPLE_PERIOD);
  //Timer3.attachInterrupt(driverP).start(SAMPLE_PERIOD);
  //Timer3.attachInterrupt(driverPD).start(SAMPLE_PERIOD);
  //Timer3.attachInterrupt(driverPI).start(SAMPLE_PERIOD);
  //Timer3.attachInterrupt(driverPID).start(SAMPLE_PERIOD);

}

void loop() {

  if(screen_print == true){
      print();
      screen_print = false;
  }
  
}

/*
* Rutina de atención a la interrupción del channel A del encoder
*/
void encoder_channelA_ISR(){
  
  if (initial_state == true) {
    // Si los valores de los dos channeles son iguales cuando se activa la interrupcion, el sentido de giro del encoder es horario
    if (digitalRead(port_channelA) == digitalRead(port_channelB)){ 
      pulses_counter = pulses_counter + 1;
    }
    else{
      pulses_counter = pulses_counter - 1;
    }
  }

  if ((pulses_counter == 0) && (digitalRead(port_channelA) == 0) && (digitalRead(port_channelB) == 0)){ 
    initial_state = true;
  }

}

/*
* Rutina de atención a la interrupción del channel B del encoder
*/
void encoder_channelB_ISR(){

 // Si los valores de los dos channeles son distintos cuando se activa la interrupcion, el sentido de giro del encoder es horario
  if (initial_state == true) {
    if (digitalRead(port_channelA) != digitalRead(port_channelB)){ 
      pulses_counter = pulses_counter + 1;
    }
    else{
      pulses_counter = pulses_counter - 1;
    }
  }

  if ((pulses_counter == 0) && (digitalRead(port_channelA) == 0) && (digitalRead(port_channelB) == 0)){ 
    initial_state = true;
  }
  
}

/* 
* Funcion que print en el terminal [timer_counter, pulses_counter]
*/
void print(){
  for(int i =0;i<=7000;i++){
    Serial.print(i);
    Serial.print(" ");
    Serial.println(buffer_driver[i]);
  }
}

/* 
* Funcion para el correcto Modeling del motor
* Entre 0 y 600 ms el motor proporciona V voltios
* Entre 600 y 1200 ms el motor proporciona 0 voltios
* Almacena el numero de pulsos en un buffer
*/
void EngineModeling(){

  if (timer_counter <= MODELING_PERIOD){

    buffer_modeling[timer_counter]=getPulses();

    if (timer_counter <= (MODELING_PERIOD/2)) {
      setVoltage(VOLTAGE);
    }
    else{
      setVoltage(0);
    }
  } 

  timer_counter++;  // Aumenta el contador cada 1ms

  if (timer_counter > MODELING_PERIOD) {
    Timer3.stop();
    screen_print = true;
    timer_counter = 0;
  }

}

/* 
* Establece un determinado voltaje en el motor
* VOLTAGE € (-inf, inf)
*/
void setVoltage(float VOLTAGE){
  
  if (VOLTAGE > MAX_VOLTAGE){
    VOLTAGE = MAX_VOLTAGE;
  }
  else if (VOLTAGE < - MAX_VOLTAGE){
    VOLTAGE = -MAX_VOLTAGE;
  }

  // VOLTAGE = duty_cycle * 12 V (MAX_VOLTAGE)
  duty_cycle = (VOLTAGE/MAX_VOLTAGE)*100; // expresado en %
  
  change_PWM(duty_cycle); 

}

/*
* Devuelve el numero de pulsos que ha contado el encoder
*/
int getPulses(){
  return pulses_counter;
}

/*
* Convierte los pulsos de la salida en radianes
*/
float getPosition(){
  float y = (getPulses()*TWO_PI)/PULSES_REVOLUTION; // Posicion en la salida; Theta [rad]
  return y;
}

/*
* Convierte el angle de entrada en pulsos del encoder
*/
float getInputPosition(){
  float r = (angle*PULSES_REVOLUTION)/(TWO_PI);
  return r;
}

/*
* Controlador Proporcional (P)
* Se llama cada vez que hay una interrupción del timer
*/
void driverP(){
   error = angle - getPosition(); // e[rad] = r[rad] - y[rad]

   U = K_P * error; //señal de control
   buffer_driver[timer_counter]=abs(getPulses()); //El numero de pulsos que se guarda en el buffer son positivos para facilitar su análisis más adelante.
   timer_counter++;  // Aumenta el contador cada 1ms

  setVoltage(U);

   if(timer_counter > 7000){
     Timer3.stop();
     screen_print = true;
     timer_counter = 0;
   }
}

/*
* Controlador Proporcional Derivativo (PD)
* Se llama cada vez que hay una interrupción del timer
*/
 void driverPD(){

   last_error = error;
   error = angle - getPosition(); // e[rad] = r[rad] - y[rad]
  
   derivative_error = (error - last_error)/(0.001); // e· = e[k] - e[k-1]) / T
   U = K_P * error + K_P*TAO_D*derivative_error; //señal de control

   buffer_driver[timer_counter]=abs(getPulses()); //El numero de pulsos que se guarda en el buffer son positivos para facilitar su análisis más adelante.
   timer_counter++;  // Aumenta el contador cada 1ms

   setVoltage(U);
   
    if(timer_counter > 7000){
        Timer3.stop();
        screen_print = true;
        timer_counter = 0;
   }

}

/*
* Controlador Proporcional Integral (PI)
* Se llama cada vez que hay una interrupción del timer
*/
 void driverPI(){

   error = angle - getPosition(); // e[rad] = r[rad] - y[rad]
  
   integral_error = (integral_error + error)*(0.001);
   U = K_P * error + (K_P*integral_error)/(TAO_I); //señal de control
  
   buffer_driver[timer_counter]=abs(getPulses()); //El numero de pulsos que se guarda en el buffer son positivos para facilitar su análisis más adelante.
   timer_counter++;  // Aumenta el contador cada 1ms

   setVoltage(U);

   if(timer_counter > 7000){
     Timer3.stop();
     screen_print = true;
     timer_counter = 0;
   }

 }


/*
* Controlador Proporcional Integral Derivativo (PID)
* Se llama cada vez que hay una interrupción del timer
*/
void driverPID(){

  last_error = error;

  error = angle - getPosition(); // e[rad] = r[rad] - y[rad]

  derivative_error = (error - last_error)/(0.001); // e· = e[k] - e[k-1]) / T

  U = (K_P * error) + (K_P*TAO_D*derivative_error) + ((K_P*integral_error)/(TAO_I)); //señal de control

  buffer_driver[timer_counter]=abs(getPulses()); //El numero de pulsos que se guarda en el buffer son positivos para facilitar su análisis más adelante.
  timer_counter++;  // Aumenta el contador cada 1ms

  setVoltage(U);
  
  if(timer_counter > 7000){
    Timer3.stop();
    screen_print = true;
    timer_counter = 0;
  }

}

/* 
* PWM HARDWARE
* Configuración del PWM
* Eleva la FREQUENCY de modulacion al menos a 20 kHz
*/
void configure_PWM(float duty_cycle){
  
  int value_CPRD = (int) (FREQUENCY_MCK/FREQUENCY);
  uint16_t pwm_level = abs((duty_cycle/100)) * value_CPRD;
      
  // Se inabilita la protección contra escritura del periférico, poniendolo a 0 (561)
  REG_PIOC_WPMR &= !TC_WPMR_WPEN;

  // PMC Pheripherial Clock Enable Register 1 (563)
  REG_PMC_PCER1 |= PMC_PCER1_PID36; // Se habilita el correspondiente reloj del periférico, poniendolo a 1

  // PWM Pheripherial Select Register. Periférico B (656)
  REG_PIOC_ABSR |= PIO_ABSR_P3;
  REG_PIOC_ABSR |= PIO_ABSR_P5;

  // PIO Disable Register. Los pines sean controlado por los periféricos, en lugar del PIO (634)
  REG_PIOC_PDR = PIO_PDR_P3 | PIO_PDR_P5;
  //REG_PIOC_PDR |= PIO_PDR_P5;

  // PWM Clock Register (1006)
  REG_PWM_CLK |= PWM_CLK_DIVB(1); // CLKB clock está controlado por PREB
  REG_PWM_CLK |= PWM_CLK_PREB(0); // MCK

  // PWM Channel Mode Register (1044)
  // Grupo 0
  REG_PWM_CMR0 |= PWM_CMR_CPRE_CLKB;
  REG_PWM_CMR0 &= !PWM_CMR_CALG;
  REG_PWM_CMR0 &= !PWM_CMR_CES;
  REG_PWM_CMR0 |= PWM_CMR_CPOL;

  // Grupo 1
  REG_PWM_CMR1 |= PWM_CMR_CPRE_CLKB;
  REG_PWM_CMR1 &= !PWM_CMR_CALG;
  REG_PWM_CMR1 &= !PWM_CMR_CES;
  REG_PWM_CMR1 |= PWM_CMR_CPOL;

  // PWM Channel Period Register (1048)
  REG_PWM_CPRD0 |= PWM_CPRD_CPRD(value_CPRD);
  REG_PWM_CPRD1 |= PWM_CPRD_CPRD(value_CPRD);

  //PWM Channel Duty-Cycle Register (1046)
  if(duty_cycle >= 0){ // Si el duty cycle es positivo se mueve en sentido horario
    REG_PWM_CDTY0 |= PWM_CDTY_CDTY(0);
    REG_PWM_CDTY1 |= PWM_CDTY_CDTY(pwm_level);
  }
  else{ // Si el duty cycle es negativo se mueve en sentido horario
    REG_PWM_CDTY0 |= PWM_CDTY_CDTY(pwm_level);
    REG_PWM_CDTY1 |= PWM_CDTY_CDTY(0);
  }
  
  // PWM Enable Register 
  REG_PWM_ENA |= PWM_ENA_CHID0;
  REG_PWM_ENA |= PWM_ENA_CHID1;

}

void change_PWM(float duty_cycle){
  
  int value_CPRD = (int) (FREQUENCY_MCK/FREQUENCY);
  uint16_t pwm_level = abs((duty_cycle/100)) * value_CPRD;
      
  //PWM Channel Duty-Cycle Register (1046)
  if(duty_cycle >= 0){ // Si el duty cycle es positivo se mueve en sentido horario
    REG_PWM_CDTYUPD0 |= PWM_CDTYUPD_CDTYUPD(0);
    REG_PWM_CDTYUPD1 |= PWM_CDTYUPD_CDTYUPD(pwm_level);
  }
  else{ // Si el duty cycle es negativo se mueve en sentido horario
    REG_PWM_CDTYUPD0 |= PWM_CDTYUPD_CDTYUPD(pwm_level);
    REG_PWM_CDTYUPD1 |= PWM_CDTYUPD_CDTYUPD(0);
  }
}

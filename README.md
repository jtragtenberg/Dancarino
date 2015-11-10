# Dancarino
open source IMU

23/10/2015
Fala Rodrigo, novas instruções para o commit "adicionei arquivos de arduino e processing do Motioner para ler RAW e…":

Pelo código estar uma gambiarra só, primeiro estude os quaternions e só depois mande esse código novo pro arduino pra ver os dados RAW... 
e pra te ajudar no descoberta de como os quaternions funcionam:
q = <qw,qx,qy,qz> = <cos(teta/2) , x*sen(teta/2) , y*sen(teta/2) , z*sen(teta/2)>
onde x,y,z é o eixo para onde aponta o vetor que representa o quaternion e teta é o angulo de rotação em torno desse eixo.
tenta descobrir como retornar a partir do quaternion os valores de x,y,z e teta limpos...
Ah! descobri!
olha esse site aqui: http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/
brincando com uma identidade trigonométrica básia se descobre que:
teta = 2 * acos(qw)
x = qx / sqrt(1-qw*qw)
y = qy / sqrt(1-qw*qw)
z = qz / sqrt(1-qw*qw)

de mão bejada pra tu! (assim fica fácil...)


Depois de ter dominado os quaternions, pra testar o lance com os valores RAW dos sensores, tu faz o seguinte: Pega na pasta /Arduino a pasta IMUDebug. Ali tem o firmware pra mandar os dados calibrados dos sensores e na pasta libraries tem as bibliotecas que ele depende. Tu deve colocar todas as bibliotecas da pasta libraries na pasta do teu computador (X:\My Documents\Arduino\libraries\). Aí tu abre com a ide do arduino o IMUDebug.ino e upa ele pro arduino naquele esquema que eu te falei (escolhe a placa Arduino UNO em Tools>Boards e a porta serial que ele tá em Tools>Serial Port. Aí dá o Run e é só alegria (finger-crossed)
Daí em diante o arduino vai estar com esse firmware e só vai dar pra rodar os novos programas de processing que eu coloquei na pasta /Processing.
São os programas (todos eles levam em conta o magnetometros e as calibrações que já estão na memória EEPROM do arduino): 
IMUVisualization //gera uma visualização a partir dos dados de Yaw Pitch e Roll do sensor e retorna todos os valores de YPR
razorReadYPR //lê direto os valores Yaw Pitch e Roll do sensor
razorReadRaw //lê os valores brutos dos sensores
razorReadGyro //lê só os valores do giroscópio (n tenho certeza se esse funciona)

beleza?

qq coisa a gente se fala


abração.




Oi Rodrigo
O arduino que fiz pra vcs com o MPU6050 e o HMC5883L já está com o código MPU6050_DMP6.
Para fazer o IMU rodar agora, precisa 
- instalar o processing 2;
- clonar esse repositório
- instalar as bibliotecas que estão aqui no git na pasta /Processing/Libraries (pra fazer isso copia as duas pastas pra pasta /Processing/libraries;
- dar três pulinhos
- abrir o código Teapot que ta na pasta Processing
- conectar o arduino no usb
- executar o código do processing
- se aparecer alguma mensagem de erro, da uma olhada no numero das portas seriais e muda a variavel PORT_NUMBER para o numero da porta em que está conectado o arduino. (Se não sabe qual eh a porta tira e ve qual da lista sumiu...). Elas estão expostas na ordem 0, 1, 2,... Vai ser alguma COM# no windows...
- veja o aviãzinho girar com os quaternions...
- descubra agora no código como ele faz isso e se estiver muito pilhado tenta implementar o mesmo código no OpenFrameWorks

abração!

ps. as vezes da um mal contato com o USB e precisa tirar da usb, colocar denovo e reiniciar o código do processing

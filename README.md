# Dancarino
open source IMU

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

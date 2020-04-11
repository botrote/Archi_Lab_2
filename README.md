모든 변수 이름이나 모듈 이름은 랩 자료 마지막 페이지에 나오는 사진에서 따옴
FIN: 완성, ING: 진행 중, () 없는건 아직 시작 x


진행 현황
Adder.v (FIN)
PC 업데이트시 사용되는 단순 덧셈만 하는 모듈

Alu.v (ING)
Control_unit.v에서 출력되는 ALUOp 이라는 변수에 맞게 operation 수행.  FUNC_SUB 인 경우에서  하던데 한 번 확인 좀, 나머지는 끝

Control_unit.v (ING)
TSC instruction field에 맞게 control signal 출력하게 만들고 있는 중, R-type, I-type, J-type 맞게 계속 추가 중

cpu.v
다른 구성원 다 마무리하고 구현하면 될 듯

Data_memory.v (무시해도 됨, 이미 주어지는거 까먹고 그냥 살짝 구현한거)

Multiplexer.v (FIN)
Input이 2개인 MUX
수업 시간에 배운 input 3개 있는거도 그냥 input 2개 있는 MUX 2개로 구현하기

Register_file.v (FIN)
Register 4개 포함하고 있음, 다 구현했는데 혹시나 모르니까 한 번만 읽어봐죠

Sign_extender.v (FIN)
했는데 보면 알겠지만 define WORD_SIZE를 사용해도 되는지는 살짝? 의문, 안 된다면 단순히 그냥 숫자로 하면 됨



바탕은 이걸로
https://github.com/EternalFeather/Single-Cycle-MIPS-CPU
# VLIW-Processor
## Features:
<ul> 
  <li>
    Multiple Functional Units
    <ul> 
      <li>
        Carry Look ahead Adder
      </li>
      <li>
        Wallace Tree Multiplier
      </li>
      <li>
        Double Precision Floating Point Adder
      </li>
      <li>
        Double Precision Floating Point Multiplier
      </li>
      <li>
        Logic Unit
      </li>
    </ul>
  </li>
  <li>
    Six independent operations are grouped together in a single VLIW Instruction. They are initialized in the same clock cycle.
  </li>
  <li>
    Each operation is assigned an independent functional unit.
  </li>
  <li>
    All the functional units share a common register file. It has 32 registers each 64 bit wide
  </li>
  <li>
    Instruction Format
    <ul>
      <li>
        Arithmetic/Logic operations- Opcode(6 bit) Rdst(5 bit),Rsrc1(5 bit),Rsrc2(5 bit)
      </li>
      <li>
        Load/Store- Opcode(6 bit) Rdst(5 bit),addr(constant), 
        Immediate Addressing Mode used 
      </li>
    </ul>
  </li>
  <li>
    Instruction scheduling and parallel dispatch of the instruction word is done statically.
  </li>
  <li>
   Dependencies are checked before scheduling parallel execution of the instructions.
  </li>
</ul>
      

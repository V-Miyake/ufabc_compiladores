grammar ExpressionGrammar;

@header{
	import java.util.Stack;
	import io.compiler.runtime.*;
}

@members{
    private Stack<AbstractExpression> stack = new Stack<AbstractExpression>();
	private AbstractExpression topo = null;
	
    public double generateValue(){
       if (topo == null){
          topo = stack.pop();
       }
       return topo.evaluate();
    }
    
    public String generateJSON(){
    	if (topo == null){
          topo = stack.pop();
       }
       return topo.toJson();
    }
}

expr_rel: termo_rl rel_expr 
		| termo_rl
		;
		
rel_expr: OP_REL termo_rl 
		;
		
termo_rl: expr | TEXTO
		;

expr	: termo	exprl
		;
		
exprl	: ((OP_SUM | OP_SUB)
		   { 
               BinaryExpression bin = new BinaryExpression(_input.LT(-1).getText().charAt(0));
               bin.setLeft(stack.pop());
               stack.push(bin);
           }    
    
         termo  
           {
         	   AbstractExpression topo = stack.pop(); // desempilhei o termo
         	   BinaryExpression root = (BinaryExpression) stack.pop(); // preciso do componente binário
         	   root.setRight(topo);
         	   stack.push(root);
           }
         
         )* 
		;	
		
termo	: fator	termol
		;
		
termol	: ((OP_MUL | OP_DIV)
			 {
			 BinaryExpression bin = new BinaryExpression(_input.LT(-1).getText().charAt(0));
			 if (stack.peek() instanceof UnaryExpression) { // o que tem no topo é um operador "simples"
			 	bin.setLeft(stack.pop()); // desempilho já tornando ele filho da multiplicacao
			 }
			 else{
			    BinaryExpression father = (BinaryExpression)stack.pop();
			    if (father.getOperation() == '-' || father.getOperation() == '+'){
			    	bin.setLeft(father.getRight());
			    	father.setRight(bin);
			    }
			    else{
			        bin.setLeft(father);
			        stack.push(bin);			       
			    }
			 }        
          }          
          fator
          {
             bin.setRight(stack.pop());
             stack.push(bin);
             System.out.println("DEBUG - :" + bin.toJson());		
          }
          
          )*		
		;
		
fator	: NUM {
                 UnaryExpression element = new UnaryExpression(Double.parseDouble(_input.LT(-1).getText()));
                 stack.push(element);
              }
		|LETRA {
				 VariableExpression element = new VariableExpression(_input.LT(-1).getText());
                 stack.push(element);
               }
		|TEXTO {
				 VariableExpression element = new VariableExpression(_input.LT(-1).getText());
                 stack.push(element);
               }
		;
		
PV		: ';'
		;
		
OP_SUM	: '+'
		;
		
OP_SUB	: '-'
		;

OP_MUL	: '*'
		;
		
OP_DIV	: '/'
		;
		
OP_REL  : '>' | '<' | '>=' | '<= ' | '<>' | '=='
		;		

NUM		:  ('-')?[0-9]+('.'[0-9]+)?
		;
	
LETRA	: [a-zA-Z]
		;
		
TEXTO   : '"' ( [a-z] | [A-Z] | [0-9] | ',' | '.' | ' ' | '-' )* '"'
		;
		
WS		: (' '|'\n'|'\r'|'\t') () -> skip
		;
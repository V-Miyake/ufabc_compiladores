grammar UFABCGrammar;

@header {
	import java.util.ArrayList;
	import java.util.List;
	import java.util.Stack;
	import java.util.HashMap;
	import io.compiler.types.*;
	import io.compiler.core.exceptions.*;
	import io.compiler.core.ast.*;
	import io.compiler.core.exprEval.*;
}

@members {
    private HashMap<String,Var> symbolTable = new HashMap<String, Var>();
    private ArrayList<Var> currentDecl = new ArrayList<Var>();
    private Types currentType;
    private Types leftType=null, rightType=null;
    private Program program = new Program();
    private String strExpr = "";
    private IfCommand currentIfCommand;
    private WhileCommand currentWhileCommand;
    private DoWhileCommand currentDoWhileCommand;
    
    private Stack<ArrayList<Command>> stack = new Stack<ArrayList<Command>>();
    
    private ExprEvaluator eval = new ExprEvaluator();
    
    public void updateType(){
    	for(Var v: currentDecl){
    	   v.setType(currentType);
    	   symbolTable.put(v.getId(), v);
    	}
    }
    public void exibirVar(){
        for (String id: symbolTable.keySet()){
        	System.out.println(symbolTable.get(id));
        }
    }
    
    public Program getProgram(){
    	return this.program;
    	}
    
    public boolean isDeclared(String id){
    	return symbolTable.get(id) != null;
    }
    
    public boolean isAllVarUsed(){
    	for (String id: symbolTable.keySet()){
        	if (symbolTable.get(id).isUsed() == false){
        		return false;
        	}
        }
    	return true;
    }
    
    public List<String> getNotUsedId(){
    	List<String> idList = new ArrayList<>();
    	for (String id: symbolTable.keySet()){
        	if (symbolTable.get(id).isUsed() == false)
        		idList.add(id);
        	}
        return idList;
    }
}
 
programa	: 'programa' ID  { program.setName(_input.LT(-1).getText());
                               stack.push(new ArrayList<Command>()); 
                             }
               declaravar+
               'inicio'
               comando+
               'fim'
               'fimprog'
               
               { if (!isAllVarUsed()) {
                       throw new UFABCSemanticException("Variable not used: " + getNotUsedId());
                   }
               }
               
               {
               	  
               	  
                  program.setSymbolTable(symbolTable);
                  program.setCommandList(stack.pop());
               }
			;
						
declaravar	: 'declare' { currentDecl.clear(); } 
               ID  { currentDecl.add(new Var(_input.LT(-1).getText()));}
               ( VIRG ID                
              		 { currentDecl.add(new Var(_input.LT(-1).getText()));}
               )*	 
               DP 
               (
               'number' {currentType = Types.NUMBER;}
               |
               'realnumber' {currentType = Types.REALNUMBER;}
               |
               'text' {currentType = Types.TEXT;}
               ) 
               
               { updateType(); } 
               PV
			;
			
comando     :  cmdAttrib
			|  cmdLeitura
			|  cmdEscrita
			|  cmdIF
			|  cmdWhile
			|  cmdDoWhile
			;
			
cmdIF		: 'se'  { stack.push(new ArrayList<Command>());
                      strExpr = "";
                      currentIfCommand = new IfCommand();
                    } 
               AP 
               expr
               OPREL  { strExpr += _input.LT(-1).getText(); }
               expr 
               FP  { currentIfCommand.setExpression(strExpr); }
               'entao'  
               comando+                
               { 
                  currentIfCommand.setTrueList(stack.pop());                            
               }  
               ( 'senao'  
                  { stack.push(new ArrayList<Command>()); }
                 comando+
                 {
                   currentIfCommand.setFalseList(stack.pop());
                 }  
               )? 
               'fimse' 
               {
               	   stack.peek().add(currentIfCommand);
               }  			   
			;

cmdWhile	:  'enquanto' { stack.push(new ArrayList<Command>());
							strExpr = "";
							currentWhileCommand = new WhileCommand();
						  }
			   AP
			   expr
			   OPREL { strExpr += _input.LT(-1).getText(); }
			   expr
			   FP	{ currentWhileCommand.setExpression(strExpr); }
			   'faca'
			   comando+
	   		   {
	    	   		currentWhileCommand.setWhileList(stack.pop());
	   		   }
			   'fimenquanto'
			   {
			   		stack.peek().add(currentWhileCommand);
			   }
			;
			
cmdDoWhile	: 'faca' { stack.push(new ArrayList<Command>());
					   currentDoWhileCommand = new DoWhileCommand();
					 } 
			  comando+
			  {
	    	   		currentDoWhileCommand.setDoWhileList(stack.pop());
	   		  }
	   		  'enquanto'
	   		  AP
	   		  {
	   		   	   	strExpr = "";
	   		  }
	   		  expr
	   		  OPREL { strExpr += _input.LT(-1).getText(); }
	   		  expr
	   		  FP { currentDoWhileCommand.setExpression(strExpr); }
	   		  {
			   		stack.peek().add(currentDoWhileCommand);
			  }
			;
			
cmdAttrib   : ID { if (!isDeclared(_input.LT(-1).getText())) {
                       throw new UFABCSemanticException("Undeclared Variable: "+_input.LT(-1).getText());
                   }
                   symbolTable.get(_input.LT(-1).getText()).setInitialized(true);
                   symbolTable.get(_input.LT(-1).getText()).setUsed();
                   leftType = symbolTable.get(_input.LT(-1).getText()).getType();
                 }
                 {
                  AttribCommand cmdAttrib = new AttribCommand(symbolTable.get(_input.LT(-1).getText()));
                  stack.peek().add(cmdAttrib);
                  strExpr = "";
                 }
              OP_AT 
              expr {cmdAttrib.setExpression(strExpr);}
              PV
              {
                 //System.out.println("Left  Side Expression Type = "+leftType);
                 //System.out.println("Right Side Expression Type = "+rightType);
                 if (leftType.getValue() < rightType.getValue()){
                    throw new UFABCSemanticException("Type Mismatchig on Assignment");
                 }
              }
               { rightType = null;}
			;			
			
cmdLeitura  : 'leia' AP 
               ID { if (!isDeclared(_input.LT(-1).getText())) {
                       throw new UFABCSemanticException("Undeclared Variable: "+_input.LT(-1).getText());
                    }
                    symbolTable.get(_input.LT(-1).getText()).setInitialized(true);
                    symbolTable.get(_input.LT(-1).getText()).setUsed();
                    Command cmdRead = new ReadCommand(symbolTable.get(_input.LT(-1).getText()));
                    stack.peek().add(cmdRead);
                  } 
               FP 
               PV 
			;
			
cmdEscrita  : 'escreva' AP 
              ( termo  {if (!_input.LT(-1).getText().startsWith("\"")) {
              				Command cmdWrite = new WriteCommand(symbolTable.get(_input.LT(-1).getText()));
              				stack.peek().add(cmdWrite);
              			}
              			else {
              				Command cmdWrite = new WriteCommand(_input.LT(-1).getText());
              				stack.peek().add(cmdWrite);
              			}
                       }  
              ) 
              FP PV { rightType = null;}
			;			
			
expr		:  termo  { strExpr += _input.LT(-1).getText(); } exprl
			{
				{System.out.println("chamando evaluate: " + strExpr);}
				eval.evaluateExpr(strExpr);
			}
			;
			
termo		: ID  { if (!isDeclared(_input.LT(-1).getText())) {
                       throw new UFABCSemanticException("Undeclared Variable: "+_input.LT(-1).getText());
                    }
                    if (!symbolTable.get(_input.LT(-1).getText()).isInitialized()){
                       throw new UFABCSemanticException("Variable "+_input.LT(-1).getText()+" has no value assigned");
                    }
                    if (rightType == null){
                       rightType = symbolTable.get(_input.LT(-1).getText()).getType();
                       //System.out.println("Encontrei pela 1a vez uma variavel = "+rightType);
                    }   
                    else{
                       if (symbolTable.get(_input.LT(-1).getText()).getType().getValue() > rightType.getValue()){
                          rightType = symbolTable.get(_input.LT(-1).getText()).getType();
                          //System.out.println("Ja havia tipo declarado e mudou para = "+rightType);
                          
                       }
                    }
                  }   
			| INT    {  if (rightType == null) {
			 				rightType = Types.NUMBER;
			 				//System.out.println("Encontrei um numero pela 1a vez "+rightType);
			            }
			            else{
			                if (rightType.getValue() < Types.NUMBER.getValue()){			                    			                   
			                	rightType = Types.NUMBER;
			                	//System.out.println("Mudei o tipo para Number = "+rightType);
			                }
			            }
			         }
			| REAL    {  if (rightType == null) {
			 				rightType = Types.REALNUMBER;
			 				//System.out.println("Encontrei um numero real pela 1a vez "+rightType);
			            }
			            else{
			                if (rightType.getValue() < Types.REALNUMBER.getValue()){			                    			                   
			                	rightType = Types.REALNUMBER;
			                	//System.out.println("Mudei o tipo para RealNumber = "+rightType);
			                }
			            }
			         }
			| TEXTO  {  if (rightType == null) {
			 				rightType = Types.TEXT;
			 				//System.out.println("Encontrei pela 1a vez um texto ="+ rightType);
			            }
			            else{
			                if (rightType.getValue() < Types.TEXT.getValue()){			                    
			                	rightType = Types.TEXT;
			                	//System.out.println("Mudei o tipo para TEXT = "+rightType);
			                	
			                }
			            }
			         }
			;
			
exprl		: ( OP { strExpr += " " + _input.LT(-1).getText() + " "; } 
                termo { strExpr += _input.LT(-1).getText(); } 
              ) *
			;	
			
OP			: '+' | '-' | '*' | '/' 
			;	
			
OP_AT	    : ':='
		    ;
		    
OPREL       : '>' | '<' | '>=' | '<= ' | '<>' | '=='
			;		    			
			
OP_ASSIGN	: ':+=' | ':-=' | ':*=' | ':/='	
			;

ID			: [a-z] ( [a-z] | [A-Z] | [0-9] )*		
			;
						
					
INT			: [0-9]+
			;

REAL		: [0-9]+ '.' [0-9]+
			;

VIRG		: ','
			;
						
PV			: ';'
            ;			
            
AP			: '('
			;            
						
FP			: ')'
			;
									
DP			: ':'
		    ;
		    
TEXTO       : '"' ( [a-z] | [A-Z] | [0-9] | ',' | '.' | ' ' | '-' )* '"'
			;		    
		    			
WS			: (' ' | '\n' | '\r' | '\t' ) -> skip
			;
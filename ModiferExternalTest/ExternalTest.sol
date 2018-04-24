pragma solidity ^0.4.21;

contract ExternalTest {
    
    event PrintMsgSender(string message, address senderAddress);
    
    function openFunction() public {
        PrintMsgSender("openFunction", msg.sender);
        calledFunction();
    }
    
    function calledFunction() public {
        PrintMsgSender("calledFunction", msg.sender);
    }
    
    function openFunction2() public {
        PrintMsgSender("openFunction2", msg.sender);
        this.calledFunction2();
    }
    
    function calledFunction2() external {
        PrintMsgSender("calledFunction2", msg.sender);
    }

}

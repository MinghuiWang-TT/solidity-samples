pragma solidity ^0.4.21;

// call(g, a, v, in, insize, out, outsize)	 	    F	call contract at address a with input mem[in..(in+insize)) providing g gas and v wei and output area mem[out..(out+outsize)) returning 0 on error (eg. out of gas) and 1 on success
// callcode(g, a, v, in, insize, out, outsize)	 	F	identical to call but only use the code from a and stay in the context of the current contract otherwise
// delegatecall(g, a, in, insize, out, outsize)	 	H	identical to callcode but also keep caller and callvalue
// staticcall(g, a, in, insize, out, outsize)	 	B	identical to call(g, a, 0, in, insize, out, outsize) but do not allow state modifications

interface SubjectInterface {
    function getState() external returns(uint);
    function setState(uint newState) external; 
}

contract CallingContract {
    SubjectInterface _subject;
    event PrintSender0(address senderAddress);
    event PrintValue0(uint amount);
    
   constructor(address forwadContract) public {
        _subject = SubjectInterface(forwadContract);
    }
    
    function setState(uint newState) public payable{
        emit PrintSender0(msg.sender);
        emit PrintValue0(msg.value);
        _subject.setState(newState);
    }
    
    function getState() public payable returns(uint)  {
        emit PrintSender0(msg.sender);
        emit PrintValue0(msg.value);
        return _subject.getState();
    }
    
}

contract ForwardingContract {
    event PrintSender1(address senderAddress);
    event PrintValue1(uint amount);
    
    
    function () public payable {
        emit PrintSender1(msg.sender);
        emit PrintValue1(msg.value);

        assembly {
            let callDataAddress := msize()
            //mstore(p, v)	-	F	mem[p..(p+32)) := v
            //calldatasize	 	F	size of call data in bytes
            mstore(0x40, add(callDataAddress, calldatasize()))
            //calldatacopy(t, f, s)	-	F	copy s bytes from calldata at position f to mem at position t
            calldatacopy(callDataAddress, 0, calldatasize())
            //gas	 	F	gas still available to execution
            //let res := call(div(mul(gas, 63), 64), subjectAddress, 0, callDataAddress, calldatasize, 0, 0)
            //let res := callcode(div(mul(gas, 63), 64), subjectAddress, 0, callDataAddress, calldatasize, 0, 0)
            //The address must been replaced by the SubjectContract address.This can not be done by store the address in a state variable 
            //because after cdelegatecall the storage slot where  SubjectContract address is stored will be replaced by the same slot of SubjectContract
            let res := delegatecall(div(mul(gas, 63), 64), 0xe3224c3ba5254ab1b36bac08fee6ab427f284f96, callDataAddress, calldatasize, 0, 0)
            let returnDataAddress := msize()
            //returndatasize	 	B	size of the last returndata
            mstore(0x40, add(returnDataAddress, returndatasize))
            returndatacopy(returnDataAddress,0,returndatasize)
            switch res
                case 0 {
                    //revert(p, s)	-	B	end execution, revert state changes, return data mem[p..(p+s))
                    revert(returnDataAddress,returndatasize)
                }
                default {
                    //return(p, s)	-	F	end execution, return data mem[p..(p+s))
                    return(returnDataAddress,returndatasize)
                }
        }        
    }
}

contract SubjectContract {
     uint private state;
     uint private state2;
     
     event PrintSender2(address senderAddress);
     event PrintValue2(uint amount);
     
     function setState(uint newState) public payable {       
         emit PrintSender2(msg.sender);
         emit PrintValue2(msg.value);
         state = newState;
     }
     
     function getState() public payable returns(uint) {
         emit PrintSender2(msg.sender);
         emit PrintValue2(msg.value);
         return state;
     }
     
     function () public payable {
         emit PrintSender2(msg.sender);
         emit PrintValue2(msg.value);
     }
}

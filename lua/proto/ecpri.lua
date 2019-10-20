------------------------------------------------------------------------
--- @file ecpri.lua
--- @brief enhance Common Public Radio Interface (eCPRI) utility.
--- Utility functions for the PROTO_header structs 
--- Includes:
--- - eCPRI constants
--- - eCPRI header utility
--- - Definition of eCPRI packets
------------------------------------------------------------------------

local ffi = require "ffi"
require "proto.template"
local initHeader = initHeader


---------------------------------------------------------------------------
---- eCPRI constants 
---------------------------------------------------------------------------

--- eCPRI protocol constants
local ecpri = {}

--- message type IQ Pairs
ecpri.TYPE_IQ = 0 
--- message type bit sequence
ecpri.TYPE_BIT = 1
--- message type real-time control data (PHY plane control data based on split)
ecpri.TYPE_RTCTRL = 2 
--- message type generic data transfer
ecpri.TYPE_DATA = 3
--- message type remote memory access
ecpri.TYPE_MEM = 4
--- message type one-way delay measurement
ecpri.TYPE_DELAY = 5 
--- message type remote reset
ecpri.TYPE_RESET = 6 
--- message type event indication
ecpri.TYPE_EVENT = 7 
--- message type IWF start-up
ecpri.TYPE_IWF_START = 8 
--- message type IWF operation
ecpri.TYPE_IWF_OP = 9 
--- message type IWF mapping
ecpri.TYPE_IWF_MAP = 10 
--- message type IWF delay control
ecpri.TYPE_IWF_DELAYCTRL = 11 

---------------------------------------------------------------------------
---- eCPRI header
---------------------------------------------------------------------------

ecpri.headerFormat = [[
	uint8_t		rev_res_c;
	uint8_t		msg_type;
	uint16_t	len;
]]

--- Variable sized member
ecpri.headerVariableMember = nil

--- Module for PROTO_address struct
local ecpriHeader = initHeader()
ecpriHeader.__index = ecpriHeader

--- Set the eCPRI protocol version.
--- @param int eCPRI protocol version as 4 bit integer. Is always set to 0.
function ecpriHeader:setVersion(int)
	int = int or 4
	int = band(lshift(int, 4), 0xf0)
	
	old = self.rev_res_c
	old = band(old, 0x0f)
	
	self.rev_res_c = bor(old, int)
end

--- Retrieve the eCPRI protocol version.
--- @return version as 4 bit integer.
function ecpriHeader:getVersion()
	return band(rshift(self.rev_res_c, 4), 0x0f)
end

--- Retrieve the eCPRI protocol version.
--- @return version as a string.
function ecpriHeader:getVersionString()
	return self:getVersion()
end


--- Set the concatenation bit.
--- @param int concatenation header as 1 bit integer. Is set to 0 for last payload else 1.
function ecpriHeader:setConcatenationBit(int)
	int = int or 1
	
	old = self.rev_res_c
	old = band(old, 0xfe)
	
	self.rev_res_c = bor(old, int)
end


--- Retrieve the concatenation bit.
--- @return concatenation bit as 1 bit integer.
function ecpriHeader:getConcatenationBit()
	return band(self.rev_res_c, 0x01)
end

--- Retrieve the concatenation bit.
--- @return concatenation bit as a string.
function ecpriHeader:getConcatenationBitString()
	return self:getConcatenationBit()
end

--- Set eCPRI message type.
--- @param int eCPRI message type as 8 bit integer.
function ecpriHeader:setMessageType(int) 
	self.msg_type:set(int)
end


--- Retrieve the eCPRI message type.
--- @return eCPRI message type as 8 bit integer.
function ecpriHeader:getMessageType()
	return self.msg_type:get()
end

--- Retrieve the eCPRI message type.
--- @return eCPRI message type as string.
function ecpriHeader:getMessageTypeString()
	local messageType = self:getMessageType()
	local cleartext = ""

	if messageType == ecpri.TYPE_IQ then 
		cleartext = "(IQ pairs)" 
	elseif messageType == ecpri.TYPE_BIT then
		cleartext = "(Bit Sequence)"
	elseif messageType == ecpri.TYPE_RTCTRL then
		cleartext = "(Real Time Control)"
	elseif messageType == ecpri.TYPE_DATA then
		cleartext = "(Generic Data Transfer)"
	elseif messageType == ecpri.TYPE_MEM then
		cleartext = "(Memory Access)"
	elseif messageType == ecpri.TYPE_DELAY then
		cleartext = "(One-way delay measurement)"
	elseif messageType == ecpri.TYPE_RESET then
		cleartext = "(Reset)"
	elseif messageType == ecpri.TYPE_EVENT then
		cleartext = "(Event Identification)"
	elseif messageType == ecpri.TYPE_IWF_START then
		cleartext = "(IWF Start-up)"
	elseif messageType == ecpri.TYPE_IWF_OP then
		cleartext = "(IWF Operation)"
	elseif messageType == ecpri.TYPE_IWF_MAP then
		cleartext = "(IWF Mapping)"
	elseif messageType == ecpri.TYPE_IWF_DELAYCTRL then
		cleartext = "(IWF Delay Control)"
	else
		cleartext = "(Reserved or Operator Specific)"
	end

	return format("0x%02x %s", messageType, cleartext)
end

--- Set eCPRI payload size.
--- @param int payload size as 16 bit integer.
function ecpriHeader:setPayloadLength(int) 
	self.len:set(int)
end


--- Retrieve the payload size.
--- @return payload size as 16 bit integer.
function ecpriHeader:getPayloadLength()
	return self.len:get()
end


--- Retrieve the payload size.
--- @return payload size as string.
function ecpriHeader:getPayloadLengthString()
	return self.len:getString()
end


--- Set all members of the ecpri  headr.
--- Per default, all members are set to default values specified in the respective set function.
--- Optional named arguments can be used to set a member to a user-provided value.
--- @param args Table of named arguments. Available arguments: Version, ConcatenationBit, MessageType, PayloadLength
--- @param pre prefix for namedArgs. Default 'ecpri'.
--- @code
--- fill() -- only default values
--- fill{ ecpriVersion = 0 } -- all members are set to default values with the exception of ecpriVersion 
--- @endcode
function ecpriHeader:fill(args, pre)
	args = args or {}
	pre = pre or "ecpri"

--	self:setVersion(args[pre .. "Version"])
--	self:setConcatenationBit(args[pre .. "ConcatenationBit"])
--	self:setMessageType(args[pre .. "MessageType"])
--	self:setLength(args[pre .. "PayloadLength"])
end

--- Retrieve the values of all members.
--- @param pre prefix for namedArgs. Default 'ecpri'.
--- @return Table of named arguments. For a list of arguments see "See also".
--- @see ecpriHeader:fill
function ecpriHeader:get(pre)
	pre = pre or "ecpri"

	local args = {}
	args[pre .. "Version"] = self:getVersion() 
	args[pre .. "ConcatenationBit"] = self:getConcatenationBit() 
	args[pre .. "MessageType"] = self:getMessageType() 
	args[pre .. "PayloadLength"] = self:getLength() 

	return args
end

--- Retrieve the values of all members.
--- @return Values in string format.
function ecpriHeader:getString()
	return "eCPRI ver " .. self:getVersionString() .. " concatenation " .. self:getConcatenationBitString() 
			.. " type " .. self:getMessageTypeString() .. " len " .. self:getPayloadLengthString()			
end

--- Resolve which header comes after this one (in a packet).
--- For instance: in tcp/udp based on the ports.
--- This function must exist and is only used when get/dump is executed on
--- an unknown (mbuf not yet casted to e.g. tcpv6 packet) packet (mbuf)
--- @return String next header (e.g. 'eth', 'ip4', nil)
function ecpriHeader:resolveNextHeader()
	return nil
end

--- Change the default values for namedArguments (for fill/get)
--- This can be used to for instance calculate a length value based on the total packet length
--- See proto/ip4.setDefaultNamedArgs as an example
--- This function must exist and is only used by packet.fill
--- @param pre The prefix used for the namedArgs, e.g. 'PROTO'
--- @param namedArgs Table of named arguments (see See more)
--- @param nextHeader The header following after this header in a packet
--- @param accumulatedLength The so far accumulated length for previous headers in a packet
--- @return Table of namedArgs
--- @see ecpriHeader:fill
function ecpriHeader:setDefaultNamedArgs(pre, namedArgs, nextHeader, accumulatedLength)
	-- set version
--	if not namedArgs[pre .. "Version"] then
--		namedArgs[pre .. "Version"] = 0
--	end

	-- set concatenation bit
--	if not namedArgs[pre .. "ConcatenationBit"] then
--		namedArgs[pre .. "ConcatenationBit"] = 0
--	end

	return namedArgs
end


------------------------------------------------------------------------
---- Metatypes
------------------------------------------------------------------------

ecpri.metatype = ecpriHeader


return ecpri

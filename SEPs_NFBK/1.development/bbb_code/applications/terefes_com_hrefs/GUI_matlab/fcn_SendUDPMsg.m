% function fcn_SendUDPMsg(id, payload);
function fcn_SendUDPMsg(payload)
   
   global udp_obj
   
   while(udp_obj.BytesToOutput ~= 0) ;
   end
   
%    UDP_ID = uint16(id);
%    UDP_ID_MSB = uint8(bitshift(bitand(65280,UDP_ID),-8));
%    UDP_ID_LSB = uint8(bitand(255,UDP_ID));
   pay = uint8(payload);
%    y = uint8([UDP_ID_MSB UDP_ID_LSB pay]);
%    fwrite(udp_obj, y, 'uint8');
   fwrite(udp_obj, pay, 'uint8');
   fprintf('@ Send UDP Msg --> ID: %d\n', pay(1));
   clear UDP_ID UDP_ID_MSB UDP_ID_LSB pay y
   
end
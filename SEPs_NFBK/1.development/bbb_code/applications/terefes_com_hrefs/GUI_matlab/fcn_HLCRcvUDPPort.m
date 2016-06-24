function fcn_HLCRcvUDPPort(obj, event, ref_handles)
   
   global therapy
   global target
   handles = guidata(ref_handles.output);
   len_id = 2;
   s = obj;
   
   if(mod(s.BytesAvailable,handles.length) == 0)
      while(s.BytesAvailable > 0)
         rcv = fread(s, handles.length, 'int8');
         id = typecast(int8([rcv(2) rcv(1)]),'int16');
         fprintf('@+ MSG UDP received -> ID: %d len: %d \n', id, length(rcv));
      end
   end

   guidata(ref_handles.output, handles);
   
end

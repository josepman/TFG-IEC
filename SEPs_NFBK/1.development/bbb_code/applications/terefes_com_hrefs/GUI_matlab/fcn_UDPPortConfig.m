function fcn_UDPWritePortConfig(ref_handles)

   global udp_obj
   
   handles = guidata(ref_handles.output);
   
   UDPDATASIZE = handles.length;
   REMOTEPORT = str2double(get(handles.UDPsend,'String'));
   LOCALPORT = str2double(get(handles.UDPreceive,'String'));
   REMOTEIP = '192.168.7.2';
   udp_obj = udp(REMOTEIP, REMOTEPORT);
   set(udp_obj, 'LocalPort', LOCALPORT);
   set(udp_obj, 'InputBufferSize', 4096);
   set(udp_obj, 'OutputBufferSize', 4096);
   set(udp_obj, 'BytesAvailableFcnMode', 'Byte');
   set(udp_obj, 'BytesAvailableFcnCount', UDPDATASIZE);
%    set(udp_obj, 'DatagramTerminateMode', 'OFF');
   udp_obj.BytesAvailableFcn = {@fcn_HLCRcvUDPPort, handles};
   fopen(udp_obj);
   
   fprintf('+++ UDP Port Opened\n');
   fprintf('\t .RemoteIP: %s\t.REMOTEPORT: %d\t.LocalPORT: %d\n', REMOTEIP, REMOTEPORT, LOCALPORT);
   
   guidata(ref_handles.output, handles);
   
end
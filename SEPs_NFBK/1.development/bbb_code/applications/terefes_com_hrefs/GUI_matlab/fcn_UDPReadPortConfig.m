function fcn_UDPReadPortConfig(ref_handles)

   global udpR_obj
   
   handles = guidata(ref_handles.output);
   
   UDPDATASIZE = handles.length;
   LOCALPORT = str2double(get(handles.UDPrport,'String'));
   REMOTEIP = '255.255.255.255';
   udpR_obj = udp(REMOTEIP);
   set(udpR_obj, 'LocalPort', LOCALPORT);
   set(udpR_obj, 'InputBufferSize', 4096);
   set(udpR_obj, 'OutputBufferSize', 4096);
   set(udpR_obj, 'BytesAvailableFcnMode', 'Byte');
   set(udpR_obj, 'BytesAvailableFcnCount', UDPDATASIZE);
%    set(udpR_obj, 'DatagramTerminateMode', 'OFF');
   udpR_obj.BytesAvailableFcn = {@fcn_HLCRcvUDPPort, handles};
   fopen(udpR_obj);
   fprintf('+++ UDP Port Opened\n');
   fprintf('\t .RemoteIP: %s\t.LocalPORT: %d\n', REMOTEIP, LOCALPORT);
   fprintf('\t .DataSIZE: %d\n', UDPDATASIZE);
   
   guidata(ref_handles.output, handles);
   
end
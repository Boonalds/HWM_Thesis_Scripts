function pushbutton1_Callback(hObject, eventdata, handles)

axes(handles.axes1);
I = imread('coins.png');
imshow(I);
message = sprintf('Click points.\nHit return when done.');
button = questdlg(message, 'Continue?', 'Yes', 'No', 'Yes');
drawnow;	% Refresh screen to get rid of dialog box remnants.
if strcmpi(button, 'No')
   return;
end
[x,y] = ginput();
counter = length(x);
disp(counter)
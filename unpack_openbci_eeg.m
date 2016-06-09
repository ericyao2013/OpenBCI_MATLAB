%
% Function to be used with OpenBCI 32bit board "chipkit". With this hardware,
% the dongle gets the data from the board and broadcast it on the serial 
% port: COM8, using the FTDI driver. This function take it after the packet
% has been read from the serial port. It unpacks the eeg signals (8 channels)
% and return them in a row array.
%
% Input:
%   packet, a 33 bytes long column vector, containing the data
%
% Output:
%   eeg_data, row-vector with 8 unsigned integers.
%
% Packet overview:
%
% Header
% Byte 1: 0xA0
% Byte 2: Sample Number
% EEG Data
% Note: values are 24-bit signed, MSB first
% Bytes 3-5: Data value for EEG channel 1
% Bytes 6-8: Data value for EEG channel 2
% Bytes 9-11: Data value for EEG channel 3
% Bytes 12-14: Data value for EEG channel 4
% Bytes 15-17: Data value for EEG channel 5
% Bytes 18-20: Data value for EEG channel 6
% Bytes 21-23: Data value for EEG channel 6
% Bytes 24-26: Data value for EEG channel 8
% Accelerometer Data
% Note: values are 16-bit signed, MSB first
% Bytes 27-28: Data value for accelerometer channel X
% Bytes 29-30: Data value for accelerometer channel Y
% Bytes 31-32: Data value for accelerometer channel Z
% Footer
% Byte 33: 0xC0
%
% Reference: http://docs.openbci.com/software/02-OpenBCI_Streaming_Data_Format
%
% Frederic Simard, Atom Embedded, 2015
%

%
% Function that unpacks the eeg samples from the openbci packets
%
function [ eeg_data, packet_numbers] = unpack_openbci_eeg( packet, nb_packets )

openbci_constants;

% initialize output buffers
eeg_data = zeros(nb_packets,NB_CHANNELS);
packet_numbers = zeros(nb_packets,1);
read_state = 0;

for ii=1:nb_packets

    offset = (ii-1)*DATA_PACKET_LENGTH;

    %warning(strcat('packet_start:', num2str(packet(1+offset))));
    assignin('base', 'packet', packet);
	assignin('base', 'offset', offset);
	packet
    offset
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % READ SERIAL BINARY
    %
    % START BYTE AND ID
    if read_state = 1
        if packet(1+offset) ~= PACKET_FIRST_WORD
            warning('Invalid start byte')
            return;
        end
        read_state = read_state + 1
    % CHANNEL DATA
    if read_state = 2







    % check if the first byte correspond to the
    % standard
    if packet(1+offset) ~= PACKET_FIRST_WORD % PACKET_FIRST_WORD = 0xa0 or 160

        % show the packet for debuggin purpose
		%warning('Invalid packet format:');
        %packet
        %warning('Invalid packet format -- END');
		
		%pause;
		
        return;
    end
    

    if length(packet) < 33

        % show the packet for debuggin purpose
		warning('Invalid packet format:');
        packet		
		%pause;
		
        return;
    end

    if packet(length(packet)) ~= PACKET_LAST_WORD % PACKET_LAST_WORD = 0xc0 or 192
        warning('Invalid end byte:')
        packet(length(packet))
        pause(2)
        return
	
	
    
    % save the packet number
    packet_numbers(ii) = packet(2+offset);
    
    % extract eeg samples (24 bits) and interpret them as signed integer 32
    eeg_data(ii,1) = int24_to_int32(packet((3:5)+offset));
    eeg_data(ii,2) = int24_to_int32(packet((6:8)+offset));
    eeg_data(ii,3) = int24_to_int32(packet((9:11)+offset));
    eeg_data(ii,4) = int24_to_int32(packet((12:14)+offset));
    eeg_data(ii,5) = int24_to_int32(packet((15:17)+offset));
    eeg_data(ii,6) = int24_to_int32(packet((18:20)+offset));
    eeg_data(ii,7) = int24_to_int32(packet((21:23)+offset));
    eeg_data(ii,8) = int24_to_int32(packet((24:26)+offset));

    % Convert counts to microvolts
    %
    % Scale factor (Volts/count) = 4.5 Volts / gain / (2^23 - 1)
    %
    % Refer to: http://docs.openbci.com/software/02-OpenBCI_Streaming_Data_Format#openbci-v3-data-format-interpreting-the-eeg-data
    %
    for j=1:length(eeg_data(ii))
        eeg_data(ii,j) = eeg_data(ii,j)*scale_fac_uVolts_per_count;
    end

end

end

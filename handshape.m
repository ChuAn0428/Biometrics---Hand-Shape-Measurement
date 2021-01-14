%--------------------------------------
% CSCI 59000 Biometrics - Hand Shape
% Author: Chu-An Tsai
% 02/09/2020
%--------------------------------------
% Must follow a specific order to input the lines
% F1,F2 for palm-wide; F3~F10 for finger-wide; 
% F11~F14 from the finger top to the palm(F2)

clear,clc;
% 5 photos
PICs = ["gray1.jpg" "gray2.jpg" "gray3.jpg" "gray4.jpg" "gray5.jpg"];

% Loop for 5 photos
for turns = 1 : length(PICs)
    
    % Load the images
    image = imread(PICs(turns));
    [m,n] = size(image);
    num_exec = 1;
    figure(turns);
    subplot(1,2,1);
    axis ij;
    axis manual;
    imshow(image);
    title(['Hand #',num2str(turns)]);
    hold on
    
    % Total 14 features to capture in one photo
    features = 14;   
    % Specific counter for F11~F14 features
    verti_features = 11;
    
    % start capturing the features
    for i = num_exec : features
        
        % Get the first input point
        coordinates_input1 = ginput(1);
        x1 = round(coordinates_input1(2));
        y1 = round(coordinates_input1(1));
        scatter(y1,x1,'c','LineWidth',1.5)
        hold on
        
        % Get the second input point
        coordinates_input2 = ginput(1);
        x2 = round(coordinates_input2(2));
        y2 = round(coordinates_input2(1));

        % F11~F14, do special calculations
        if num_exec >= verti_features
            
            % User input points
            A = [y1, y2];
            B = [x1, x2];
            
            % Get the gradient grayscale and coordinates
            [cx,cy,c] = improfile(image,A,B);
            
            % Record
            c_len(num_exec,1) = length(cx);
            for k = 1 : length(cx)
                cx_cy_records(k,1,num_exec) = cx(k);
                cx_cy_records(k,2,num_exec) = cy(k);
            end
            
            % Find the intersection of F2(rounded) and current feature(rounded)
            temp_1 = round(cx_cy_records(1:c_len(2),:,2));
            temp_2 = round(cx_cy_records(1:c_len(num_exec),:,num_exec));
            [C_intersect,ia,ib] = intersect(temp_1,temp_2, 'rows' );
          
            % Get the index and retrieve the true coordinates for the intersection
            [ind_row, ind_col] = find(temp_1 == C_intersect(1));
            true_Cxy = cx_cy_records(ind_row,:,2);
            
            % Plot (the first input and the intersection coordinates)
            A1 = [y1, true_Cxy(1)];
            B1 = [x1, true_Cxy(2)];
            plot(A1,B1,'c','LineWidth',1.5);
            text(A1(1)-10,B1(1)-10,['F',num2str(num_exec)],'FontSize',16);
            hold on
            
            % Plot the input line profile
            subplot(1,2,2);
            improfile(image,A1,B1);
            title(['F',num2str(num_exec)]);
            
            % calculate the gradient
            len = length(c);
            A_B = [A1;B1];
            A_B_records(:,:,num_exec) = A_B;
            diff = zeros(len,1);
            for j = 1 : len
                if j+1 < len
                    diff(j) = c(j+1) - c(j);    
                end
            end
            
            % Get the start point for the figer
            [M1,I1] = min(diff);
            
            % For F11~F14, the second point is the intersection with F2(palm)
            % Calculate the euclidean distances 
            XY1 = [cx(I1+1),cy(I1+1)];
            XY2 = [true_Cxy(1),true_Cxy(2)];
            dist = norm(XY2-XY1);
            coordi_records(1,num_exec) = dist;

            % Plot the distance in a red line
            A_red = [cx(I1+1),true_Cxy(1)];
            B_red = [cy(I1+1),true_Cxy(2)];
            subplot(1,2,1);
            plot(A_red,B_red,'-or','LineWidth',2);
            hold on
        
        % F1~F10 do the regular calculation    
        else
            % Plot the user input 
            scatter(y2,x2,'c','LineWidth',1.5 )
            hold on
            A = [y1, y2];
            B = [x1, x2];
            plot(A,B,'c','LineWidth',1.5);
            text(A(1)-10,B(1)-10,['F',num2str(num_exec)],'FontSize',16);
            hold on
            
            % Plot the input line profile
            subplot(1,2,2);
            improfile(image,A,B);
            title(['F',num2str(num_exec)]);
            
            % Get the gradient grayscale and coordinates
            [cx,cy,c] = improfile(image,A,B);
            c_len(num_exec,1) = length(cx);
            for k = 1 : length(cx)
                cx_cy_records(k,1,num_exec) = cx(k);
                cx_cy_records(k,2,num_exec) = cy(k);
            end
            len = length(c);
            A_B = [A;B];
            A_B_records(:,:,num_exec) = A_B;

            % calculate the gradient
            diff = zeros(len,1);
            for j = 1 : len
                if j+1 < len
                    diff(j) = c(j+1) - c(j);    
                end
            end
            
            % Get the start point and the end point for the palm or figer
            [M1,I1] = min(diff);
            [M2,I2] = max(diff);
            M_records(:,:,num_exec) = [M1,M2];
            
            % Calculate the euclidean distances
            XY1 = [cx(I1+1),cy(I1+1)];
            XY2 = [cx(I2+1),cy(I2+1)];
            dist = norm(XY2-XY1);
            coordi_records(1,num_exec) = dist;

            % Plot the distance in a red line
            A_red = [cx(I1+1),cx(I2+1)];
            B_red = [cy(I1+1),cy(I2+1)];
            subplot(1,2,1);
            plot(A_red,B_red,'-or','LineWidth',2);
            hold on
        end

        num_exec = num_exec + 1;
    end
    
    % Record the features from F1~F14
    feature_vectors(turns,:) = coordi_records;
end

% Do the pairwise norm error
f1 = feature_vectors(1,:);
f2 = feature_vectors(2,:);
f3 = feature_vectors(3,:);
f4 = feature_vectors(4,:);
f5 = feature_vectors(5,:);

P_1v2 = norm(f1-f2);
P_1v3 = norm(f1-f3);
P_1v4 = norm(f1-f4);
P_1v5 = norm(f1-f5);
P_2v3 = norm(f2-f3);
P_2v4 = norm(f2-f4);
P_2v5 = norm(f2-f5);
P_3v4 = norm(f3-f4);
P_3v5 = norm(f3-f5);
P_4v5 = norm(f4-f5);

% Plot the pairwise results
figure();
cat = categorical({'1v2','1v3','1v4','1v5','2v3','2v4','2v5','3v4','3v5','4v5'});
pairwise = [P_1v2,P_1v3,P_1v4,P_1v5,P_2v3,P_2v4,P_2v5,P_3v4,P_3v5,P_4v5]; 
bar(cat,pairwise);
title('The Pairwise Euclidean Distances');
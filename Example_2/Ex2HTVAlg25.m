function [err]=Ex2HTVAlg25(x)
    xnm1= x;   
    xn=xnm1;   
      
    sigma=0.59;
    mu=2;
    
    tau=0.00065;  %0.00146

    
     A=@(w) [2.3*w(1)+0.1414*w(2);-0.1414*w(1)+2*w(2)];
        
       
    N=5000;
    tol=10^(-6);

    k=1;
    err=1;
    tic;

    % Open the file for writing
    fileID = fopen('Ex2HTVAlg25', 'w');
     

    while (k <= N && err > tol)
        
        % Write output to file 
        fprintf(fileID, '%d %d \n', k, err);
        fprintf(' %d %d \n', k, err);  
        
        yn=xn+(1-sigma)*(xn-xnm1);
        term_to_project = A(xn) - mu* xn;
        proj_val = proj_K_rect(term_to_project, xn/2);
        xnp1 = yn + tau * (proj_val - A(xn));
        %xnp1=yn+tau*(proj_K_rect(A(xn)-mu*xn,[5;3])-A(xn)); 
          
        
        err= norm(xn-xnp1);   
        xnm1 = xn; 
        xn = xnp1;  

        k=k+1;
    end
    
    % Close the file
    fclose(fileID);
 toc;
end
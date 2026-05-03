function [err]=Ex1TVAlg5(x)

    xnm1= x;   
    xn=xnm1;  
      
    lam=2;
    
    alphan=0.02; %0.00146

    
    A=@(w) [2.05*w(1)+(sqrt(30)/20)*w(2);(sqrt(30)/20)*w(1)+2.15*w(2)];
        
       

    N=5000;
    tol=10^(-6);

    k=1;
    err=1;
    tic;

    % Open the file for writing
    fileID = fopen('Ex1TVAlg5', 'w');
     

    while (k <= N && err > tol)
        
        % Write output to file 
        fprintf(fileID, '%d %d \n', k, err);
        fprintf(' %d %d \n', k, err);  
        
         
        xnp1=xn+alphan*(proj_K(A(xn)-lam*xn,xn)-A(xn));
          
        
        err= norm(xn-xnp1);   
        xn=xnp1;  

        k=k+1;
    end
    
    % Close the file
    fclose(fileID);
 toc;
end
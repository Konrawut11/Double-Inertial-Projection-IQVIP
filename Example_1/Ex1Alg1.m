function [err]=Ex1Alg1(x)

    pnm1= x;   
    pn=pnm1;   
     
    tau=0.007;
    rho=0.45;
    lam=0.006;
    gama=2;
    
    alphan=0.35;

    
    A=@(w) [2.05*w(1)+(sqrt(30)/20)*w(2);(sqrt(30)/20)*w(1)+2.15*w(2)];
        
       

    N=5000;
    tol=10^(-6);

    k=1;
    err=1;
    tic;

    % Open the file for writing
    fileID = fopen('Ex1KAlg1', 'w');
     

    while (k <= N && err > tol)
        
        % Write output to file 
        fprintf(fileID, '%d %d \n', k, err);
        fprintf(' %d %d \n', k, err);  
        
        
        sn=pn+lam*(pn-pnm1);
        rn=pn+tau*(pn-pnm1);
        qn=sn+alphan*(proj_K(A(sn)-gama*sn,sn)-A(sn));
         
        pnp1=(1-rho)*rn+rho*qn; 
        
        err= norm(pn-pnp1);  
        pnm1=pn;
        pn=pnp1;  

        k=k+1;
    end
    
    % Close the file
    fclose(fileID);
 toc;
end
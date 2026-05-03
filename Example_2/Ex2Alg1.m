function [err]=Ex2Alg1(x)
    pnm1= x;   
    pn=pnm1;  
     
    tau=0.0006;
    rho=0.45;
    lam=0.0005;
    gama=2;
    
    alphan=0.01;

    
    A=@(w) [2.3*w(1)+0.1414*w(2);-0.1414*w(1)+2*w(2)];
        
       

    N=5000;
    tol=10^(-6);

    k=1;
    err=1;
    tic;

    % Open the file for writing
    fileID = fopen('Ex2KAlg1', 'w');
     

    while (k <= N && err > tol)
        
        % Write output to file 
        fprintf(fileID, '%d %d \n', k, err);
        fprintf(' %d %d \n', k, err);  
        
        
        sn=pn+lam*(pn-pnm1);
        rn=pn+tau*(pn-pnm1);
        term_to_project = A(sn) - gama* sn;
        proj_val = proj_K_rect(term_to_project, sn/2);
        %qn=sn+alphan*(proj_K_rect(A(sn)-gama*sn,[5;3])-A(sn));
        qn = sn + alphan * (proj_val - A(sn));
         
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
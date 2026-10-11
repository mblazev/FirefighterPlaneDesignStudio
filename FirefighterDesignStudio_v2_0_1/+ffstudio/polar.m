function p=polar(c)
p.LDmax=c.KLD*sqrt(c.aspectRatio/c.wettedRatio);
p.k=1/(pi*c.aspectRatio*c.oswald);
p.CD0=pi*c.aspectRatio*c.oswald/(4*p.LDmax^2);
p.CLbest=sqrt(p.CD0/p.k);
p.CL=linspace(0,2.5,251)'; p.CD=p.CD0+p.k*p.CL.^2; p.LD=p.CL./p.CD;
end

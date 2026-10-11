function a=atmosphere(h,deltaT)
if nargin<2, deltaT=0; end
assert(isnumeric(h)&&isreal(h)&&all(isfinite(h(:)))&&all(h(:)>=0&h(:)<=11000), ...
    'ffstudio:Atmosphere','Altitude must be between 0 and 11000 m.');
if exist('atmosisa','file')==2
    [T,sound,p,rho]=atmosisa(h); provider='Aerospace Toolbox atmosisa';
else
    T=288.15-.0065*h; p=101325*(T/288.15).^(9.80665/(287.05287*.0065));
    rho=p./(287.05287*T); sound=sqrt(1.4*287.05287*T);
    provider='Troposphere ISA fallback';
end
a.T_K=T+deltaT; a.p_Pa=p; a.rho_kgm3=rho.*T./a.T_K;
a.sound_ms=sound.*sqrt(a.T_K./T); a.sigma=a.rho_kgm3/1.225; a.provider=provider;
end

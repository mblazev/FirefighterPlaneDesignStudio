function r=uncertainty(c,n,seed)
if nargin<2, n=150; end
if nargin<3, seed=42; end
assert(isnumeric(n)&&isscalar(n)&&isfinite(n)&&n>=2&&n==fix(n),'ffstudio:Input','Use at least 2 samples.');
old=rng; cleanup=onCleanup(@()rng(old)); rng(seed);
z=randn(n,3); mass=nan(n,1); fuel=mass;
for i=1:n
    cc=c; cc.emptyScale=c.emptyScale*max(.7,1+.05*z(i,1));
    cc.sfcCruise_kgkWh=c.sfcCruise_kgkWh*max(.5,1+.10*z(i,2));
    cc.KLD=c.KLD*max(.5,1+.05*z(i,3));
    try
        d=ffstudio.sizeAircraft(cc,'report'); mass(i)=d.mtow_kg; fuel(i)=d.fuel_kg;
    catch err
        if ~strcmp(err.identifier,'ffstudio:Sizing'), rethrow(err); end
    end
end
r.table=table(mass,fuel,'VariableNames',{'MTOW_kg','Fuel_kg'});
s=sort(mass(isfinite(mass))); assert(~isempty(s),'ffstudio:Uncertainty','No valid mass closures.');
if isscalar(s), r.massP05P50P95_kg=repmat(s,1,3);
else, r.massP05P50P95_kg=interp1(linspace(0,1,numel(s)),s,[.05 .50 .95]); end
r.seed=seed; r.failed=nnz(~isfinite(mass));
r.note='Illustrative independent normal inputs: empty scale 5%, cruise SFC 10%, best-L/D factor 5%. These are not measured confidence bounds.';
clear cleanup;
end

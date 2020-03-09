function t=golden_section1_1(low,high,radia_ratio) 
range=high-low;
lowm=high-0.618*range; 
highm=low+0.618*range; 
[Initlm,Rlm]=initial1_1(lowm,radia_ratio); 
[Inithm,Rhm]=initial1_1(highm,radia_ratio); 
while (high-low>1e-5)
    if Rlm>Rhm
        low=lowm; range=high-low;
        lowm=high-0.618*range; highm=low+0.618*range; 
        Initlm=Inithm;Rlm=Rhm; 
        [Inithm,Rhm]=initial1_1(highm,radia_ratio);
    else
    high=highm; range=high-low;
    lowm=high-0.618*range; highm=low+0.618*range;
    Inithm=Initlm;Rhm=Rlm;
    end
end
[Initlm,Rlm]=initial1_1(lowm,radia_ratio);
t=(high+low)/2; 
end
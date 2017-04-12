y = randi(3,200,1);
x = zeros(size(y));

% Things with y=1 tend to have x values near zero.
n1 = sum(y==1);
x(y==1) = randn(n1,1)/2;

% Things with y=2 tend to have x near 3; and y=3 has x near 2
n2 = sum(y==2);
x(y==2) = 3 + randn(n2,1);
n3 = sum(y==3);
x(y==3) = 2 + randn(n3,1);

% Fit a multinomial model for y as a function of x.
b = mnrfit(x,y,'model','nominal');

% Look at the probabilities for the three categories as a function of x.
xx = linspace(min(x),max(x))';
pp = mnrval(b,xx,'model','nominal');
plot(xx,pp)
legend('Prob(y=1)','Prob(y=2)','Prob(y=3)','location','best')

% Generate predictions yyy at ten x values.
xxx = 4*rand(10,1);
ppp = mnrval(b,xxx,'model','nominal');
[maxp,yyy] = max(ppp,[],2);
t = (yyy==1); line(xxx(t),maxp(t),'color','b','marker','o','linestyle','none')
t = (yyy==2); line(xxx(t),maxp(t),'color','g','marker','s','linestyle','none')
t = (yyy==3); line(xxx(t),maxp(t),'color','r','marker','v','linestyle','none')
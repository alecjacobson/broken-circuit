
n = 100;
th = linspace(0,2*pi,n+2)';
th = th(2:end-1);
V = [cos(th) sin(th)];
%%% Can make brute force arbitrarily bad by increasing number of spikes
V = V.*sin(th*2);
%%E = [1:size(V,1)-1;2:size(V,1)]';
%% The makes bisection bad, but the effect diminishes a bit with uniform
%% resampling
%V = sign(V).*[abs(V).^0.2];
%V = uniformly_sample(V,n);

V = [
      0.6295    0.8566
    0.4422    0.8183
    0.2591    0.6736
    0.1442    0.4394
    0.3017    0.2266
    0.0931    0.1585
    0.1399    0.0691
    0.3996    0.1032
    0.5997    0.2011
    0.8508    0.1968
    0.9870    0.1287
    1.0807    0.3075
    0.7657    0.4735
    1.0381    0.5203
    1.3404    0.4437
    1.2424    0.6736
    0.9530    0.8268
    0.7444    0.8481
];

clf;
subplot(1,2,1);
title('Draw a curve');
axis equal;
%U = get_pencil_curve();
%V = uniformly_sample(U,100);
%I = convhull(V);
%V = V(I(2:end),:);
%V = uniformly_sample(V,100);


l_bf = [];
l_bi = [];
l_dp = [];
I_bf = {};
I_bi = {};
I_dp = {};
P = normrow(diff(V));P = P/sum(P);

for x = (1:size(V,1)-1)+0.5
  [l_bf(end+1),I_bf{end+1}] = find_broken_circuit(V,x,'brute-force');
  [l_bi(end+1),I_bi{end+1}] = find_broken_circuit(V,x,'bisection');
  [l_dp(end+1),I_dp{end+1}] = find_broken_circuit(V,x,'dynamic-programming');
end

CM = cbrewer('Set1',3);

subplot(1,2,2);
hist([l_bf;l_bi;l_dp]',10)
colormap(CM)
m_bf = l_bf*P;
m_bi = l_bi*P;
m_dp = l_dp*P;
leg = legend({ ...
  sprintf('brute-force (avg. %0.2f×)',m_bf/m_bf),  ...
  sprintf('bisection   (avg. %0.2f×)',m_bi/m_bf), ...
  sprintf('dynamic     (avg. %0.2f×)',m_dp/m_bf)}, ...
      'FontWeight','bold', ...
  'FontSize',20,'FontName','Courier','Location','NorthEast','Box','on');
title('Histogram of trajectory lengths','FontSize',25);

subplot(1,2,1);
cla
%[~,i] = max((l_bf./l_dp).*(l_bi./l_dp));
for i = 1:numel(l_bf)
  plt(V,'k','LineWidth',2);
  txt(V,num2str([1:size(V,1)]'),'Color',0.9*[1 1 1]);
  set(gca,'YDir','reverse');
  axis equal;
  hold on;
  plt(V(I_bf{i},:),'-o','Color',CM(1,:),'LineWidth',2);
  plt(V(I_bi{i},:),':o','Color',CM(2,:),'LineWidth',2);
  plt(V(I_dp{i},:),'--o','Color',CM(3,:),'LineWidth',2);
  plt((V(i,:)+V(i+1,:))*0.5,'xk','LineWidth',3);
  hold off;
  leg = legend({ ...
   '',...
    sprintf('brute-force (%5.2f×)',l_bf(i)/l_bf(i)),  ...
    sprintf('bisection   (%5.2f×)',l_bi(i)/l_bf(i)), ...
    sprintf('dynamic     (%5.2f×)',l_dp(i)/l_bf(i))}, ...
      'FontWeight','bold', ...
    'FontSize',20,'FontName','Courier','Location','NorthEast','Box','on');
  title(sprintf('Trajectory to find specific break'),'FontSize',25);
  drawnow;
  figgif('farm-plot.gif');
end

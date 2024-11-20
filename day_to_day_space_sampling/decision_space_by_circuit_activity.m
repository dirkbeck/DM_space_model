clear; close all
rng(0)

n_inc = 20;
n_dim = 4;

sSPN = linspace(0,5,n_inc);
daSNC = linspace(0,5,n_inc);
LHb = linspace(0,5,n_inc);

prob_space = zeros(n_inc,n_inc,n_inc,5); % last dim is the # of dec-dims in space

for i=1:n_inc
    for j=1:n_inc
        for k=1:n_inc
            p = 1/(1+exp(sSPN(i)-daSNC(j)+LHb(k))); % prob. one dim. in space
            for l=1:1+n_dim
                d = l-1; % d = number dec-dimensions in space
                prob_space(i,j,k,l) = nchoosek(n_dim,d)*p^d*(1-p)^(n_dim-d);
            end
        end
    end
end

[X,Y,Z] = meshgrid(sSPN,daSNC,LHb);
cols = colororder;
figure; hold on
for i=1:5
    visible = (rand(n_inc,n_inc,n_inc)<prob_space(:,:,:,i)) & (rand(n_inc,n_inc,n_inc)<.005);
    scatter3(Y(visible),X(visible),Z(visible),30,cols(i,:),'filled')
end
view(3)
xlabel("sSPN activity (arb. u.)")
ylabel("daSNC activity (arb. u.)")
zlabel("LHb activity (arb. u.)")
xlim([0 5]); ylim([0 5]); zlim([0 5])
legend(["decision-space not formed","1D decision-space","2D decision-space","3D decision-space","4D decision-space"])
set(gcf,'renderer','painters');

figure; hold on
for i=1:5
    for j=1:4
        s=isosurface(Y,X,Z,prob_space(:,:,:,i),j*.25);
        p = patch(s);
        isonormals(X,Y,Z,prob_space(:,:,:,i),p)
        set(p,'FaceColor',cols(i,:));  
        set(p,'EdgeColor','none');
        set(p,'FaceAlpha',j*.25)
    end
end
view(3)
xlabel("sSPN activity (arb. u.)")
ylabel("daSNC activity (arb. u.)")
zlabel("LHb activity (arb. u.)")
legend(["decision-space not formed","1D decision-space","2D decision-space","3D decision-space","4D decision-space"])
set(gcf,'renderer','painters');
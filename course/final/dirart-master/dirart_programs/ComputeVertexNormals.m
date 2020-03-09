function meshS = ComputeVertexNormals(meshS)
%
%	meshS = ComputeVertexNormals(meshS)
%
% Compute normal vector for each triangle
v1s = meshS.vertices(meshS.triangles(:,1),:)-meshS.vertices(meshS.triangles(:,2),:);
v2s = meshS.vertices(meshS.triangles(:,1),:)-meshS.vertices(meshS.triangles(:,3),:);
vcs = cross(v1s,v2s);

normals = zeros(size(meshS.vertices,1),3);
normals(meshS.triangles(:,1),:) = normals(meshS.triangles(:,1),:) + vcs(meshS.triangles(:,1),:);
normals(meshS.triangles(:,2),:) = normals(meshS.triangles(:,2),:) + vcs(meshS.triangles(:,2),:);
normals(meshS.triangles(:,3),:) = normals(meshS.triangles(:,3),:) + vcs(meshS.triangles(:,3),:);
sums = sum(normals.^2,2);
sums = repmat(sums,[1 3]);
normals = normals ./ sqrt(sums+eps);

meshS.normals = normals;


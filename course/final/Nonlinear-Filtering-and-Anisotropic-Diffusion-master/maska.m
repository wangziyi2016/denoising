function [ asd1 ] = maska( I,i,j,d )

asd1= I((i-d+1):(i+d-1),(j-d+1):(j+d-1));
end


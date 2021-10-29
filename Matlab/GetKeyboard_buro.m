function index = GetKeyboard

[keyboardIndices, productNames] = GetKeyboardIndices;

for i = 1:length(productNames)
    if productNames{i} == 'Tastatur'
        which_product = i;
    end
end

index= keyboardIndices(which_product);

end

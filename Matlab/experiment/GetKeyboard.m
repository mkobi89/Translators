function index = GetKeyboard

[keyboardIndices, productNames] = GetKeyboardIndices;

for i = 1:length(productNames)
    if productNames{i} == string('Lite-On Technology Corp. HP Wireless Slim Keyboard - Skylab EU')
        which_product = i;
    end
end

index= keyboardIndices(which_product);

end

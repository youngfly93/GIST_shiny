// 强制修复标题颜色为白色 - 超强版本
function fixTitleColors() {
    console.log('Fixing title colors...');
    
    // 选择所有主要标题元素 - 包括原始UI和重构UI的所有情况
    const titleElements = [
        ...document.querySelectorAll('h1'),
        ...document.querySelectorAll('h2[style*="text-align: center"]'),
        ...document.querySelectorAll('h2[style*="color: #1C484C"]'),
        ...document.querySelectorAll('.pageTitle'),
        ...document.querySelectorAll('[class*="pageTitle"]'),
        ...document.querySelectorAll('h1[class*="Title"]'),
        // 原始UI模块特定选择器
        ...document.querySelectorAll('#shiny-tab-module1_age h1, #shiny-tab-module1_age h2'),
        ...document.querySelectorAll('#shiny-tab-module1_cd34 h1, #shiny-tab-module1_cd34 h2'),
        ...document.querySelectorAll('#shiny-tab-module1_clinical h1, #shiny-tab-module1_clinical h2'),
        ...document.querySelectorAll('#shiny-tab-module1_gender h1, #shiny-tab-module1_gender h2'),
        ...document.querySelectorAll('#shiny-tab-module1_ki67 h1, #shiny-tab-module1_ki67 h2'),
        ...document.querySelectorAll('#shiny-tab-module1_location h1, #shiny-tab-module1_location h2'),
        ...document.querySelectorAll('#shiny-tab-module1_mitotic h1, #shiny-tab-module1_mitotic h2'),
        ...document.querySelectorAll('#shiny-tab-module1_mutation h1, #shiny-tab-module1_mutation h2'),
        ...document.querySelectorAll('#shiny-tab-module1_risk h1, #shiny-tab-module1_risk h2'),
        ...document.querySelectorAll('#shiny-tab-module1_tumor_size h1, #shiny-tab-module1_tumor_size h2'),
        ...document.querySelectorAll('#shiny-tab-module1_tvn h1, #shiny-tab-module1_tvn h2'),
        ...document.querySelectorAll('#shiny-tab-module1_who h1, #shiny-tab-module1_who h2'),
        ...document.querySelectorAll('#shiny-tab-module2 h1, #shiny-tab-module2 h2'),
        ...document.querySelectorAll('#shiny-tab-module3 h1, #shiny-tab-module3 h2'),
        ...document.querySelectorAll('#shiny-tab-module4 h1, #shiny-tab-module4 h2'),
        // 在分析模块内的所有标题
        ...document.querySelectorAll('[id*="module"] h1, [id*="module"] h2')
    ];
    
    // 修复副标题颜色 - 在浅色背景下使用深色
    const subtitleElements = [
        ...document.querySelectorAll('h2'),
        ...document.querySelectorAll('h3'),
        ...document.querySelectorAll('h4'),
        ...document.querySelectorAll('h5'),
        ...document.querySelectorAll('h6')
    ];
    
    // 处理主标题 - 设置为白色并添加绿色背景
    titleElements.forEach(element => {
        // 记录原始样式用于调试
        console.log('Main title element:', element, 'Original color:', getComputedStyle(element).color);
        
        // 超强力设置样式
        element.style.setProperty('color', 'white', 'important');
        element.style.setProperty('text-shadow', '0 1px 2px rgba(0,0,0,0.8)', 'important');
        element.style.setProperty('background-color', 'var(--clr-primary-500)', 'important');
        element.style.setProperty('padding', '15px 30px', 'important');
        element.style.setProperty('border-radius', '8px', 'important');
        element.style.setProperty('margin', '10px auto', 'important');
        element.style.setProperty('display', 'inline-block', 'important');
        
        // 添加CSS类
        element.classList.add('force-white-title');
        
        // 确保样式生效的兜底方案
        const styleString = 'color: white !important; text-shadow: 0 1px 2px rgba(0,0,0,0.8) !important; background-color: var(--clr-primary-500) !important; padding: 15px 30px !important; border-radius: 8px !important; margin: 10px auto !important; display: inline-block !important;';
        element.setAttribute('style', (element.getAttribute('style') || '').replace(/color:[^;]*;?/g, '') + '; ' + styleString);
    });
    
    // 处理副标题 - 检查背景色后设置合适颜色
    subtitleElements.forEach(element => {
        // 检查父元素的背景色
        let parentElement = element.parentElement;
        let backgroundColor = 'white'; // 默认浅色背景
        
        while (parentElement && parentElement !== document.body) {
            const bgColor = getComputedStyle(parentElement).backgroundColor;
            if (bgColor && bgColor !== 'rgba(0, 0, 0, 0)' && bgColor !== 'transparent') {
                backgroundColor = bgColor;
                break;
            }
            parentElement = parentElement.parentElement;
        }
        
        // 根据背景色设置文字颜色
        const isDarkBackground = backgroundColor.includes('72, 76') || backgroundColor.includes('#1C484C');
        
        if (isDarkBackground) {
            // 深色背景用白色文字
            element.style.setProperty('color', 'white', 'important');
            element.style.setProperty('text-shadow', '0 1px 2px rgba(0,0,0,0.5)', 'important');
        } else {
            // 浅色背景用深色文字
            element.style.setProperty('color', '#163A3D', 'important');
            element.style.setProperty('text-shadow', 'none', 'important');
        }
    });
    
    console.log('Title colors fixed for', titleElements.length, 'main titles and', subtitleElements.length, 'subtitles');
}

// 立即执行
fixTitleColors();

// 页面加载时执行
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded, fixing titles...');
    setTimeout(fixTitleColors, 50);
});

// 页面完全加载后执行
window.addEventListener('load', function() {
    console.log('Window loaded, fixing titles...');
    setTimeout(fixTitleColors, 100);
});

// Shiny相关事件
if (typeof Shiny !== 'undefined') {
    $(document).on('shiny:connected', fixTitleColors);
    $(document).on('shiny:value', function() {
        setTimeout(fixTitleColors, 50);
    });
    $(document).on('shown.bs.tab', fixTitleColors);
}

// MutationObserver 监听DOM变化
const observer = new MutationObserver(function(mutations) {
    let shouldFix = false;
    mutations.forEach(function(mutation) {
        if (mutation.type === 'childList' || mutation.type === 'attributes') {
            shouldFix = true;
        }
    });
    if (shouldFix) {
        setTimeout(fixTitleColors, 10);
    }
});

observer.observe(document.body, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ['style', 'class']
});

// 强力定期检查
setInterval(fixTitleColors, 500);

console.log('Super title color fix script loaded and active');
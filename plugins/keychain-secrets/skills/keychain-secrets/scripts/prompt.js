// 키체인 저장용 입력창. 암호 앱의 새 암호 창처럼 제목 · 사용자 이름 · 암호 · 웹사이트 · 메모를 한 창에서 받는다.
// 사용: osascript -l JavaScript prompt.js [제목] [사용자 이름] [웹사이트] [메모]
// 저장을 누르면 stdout 에 제목 · 사용자 이름 · 웹사이트 · 메모 · 암호를 한 줄씩 쓰고 종료 코드 0.
// 암호를 마지막 줄에 두어 앞 칸에 무엇이 들어가도 암호 줄 위치가 바뀌지 않게 함. 취소하면 출력 없이 종료 코드 1
ObjC.import('Cocoa');

function run(argv) {
  const app = $.NSApplication.sharedApplication;
  app.setActivationPolicy($.NSApplicationActivationPolicyAccessory);
  installEditMenu(app);

  const alert = $.NSAlert.alloc.init;
  alert.messageText = '키체인 저장';
  alert.informativeText = '제목은 env/ 로 시작 (env/ 뒤는 영문 대문자 · 숫자 · _)';
  alert.addButtonWithTitle('저장');
  alert.addButtonWithTitle('취소');
  const icon = $.NSWorkspace.sharedWorkspace.iconForFile('/System/Applications/Passwords.app');
  if (icon) {
    alert.icon = icon;
  }

  // out 은 stdout 에 쓰는 순서. 암호(out 4)는 마지막
  const fields = [
    { label: '제목', secure: false, value: argv[0] || 'env/', out: 0 },
    { label: '사용자 이름', secure: false, value: argv[1] || '', out: 1 },
    { label: '암호', secure: true, value: '', out: 4 },
    { label: '웹사이트', secure: false, value: argv[2] || '', out: 2 },
    { label: '메모', secure: false, value: argv[3] || '', out: 3 },
  ];
  const labelWidth = 90;
  const inputWidth = 300;
  const row = 30;
  const view = $.NSView.alloc.initWithFrame($.NSMakeRect(0, 0, labelWidth + inputWidth, row * fields.length));

  const inputs = fields.map((f, i) => {
    const top = row * (fields.length - 1 - i);
    const label = $.NSTextField.labelWithString(f.label);
    label.frame = $.NSMakeRect(0, top + 3, labelWidth - 8, 18);
    const input = (f.secure ? $.NSSecureTextField : $.NSTextField).alloc
      .initWithFrame($.NSMakeRect(labelWidth, top, inputWidth, 24));
    input.stringValue = f.value;
    view.addSubview(label);
    view.addSubview(input);
    return input;
  });
  inputs.forEach((input, i) => {
    input.nextKeyView = inputs[(i + 1) % inputs.length];
  });
  alert.accessoryView = view;
  // 비어 있는 첫 칸에서 시작. 모두 채워져 있으면 암호 칸
  alert.window.initialFirstResponder = inputs.find((input) => input.stringValue.js.length === 0) || inputs[2];

  app.activateIgnoringOtherApps(true);
  const answer = alert.runModal;
  if (answer !== $.NSAlertFirstButtonReturn) {
    $.exit(1);
  }
  const out = [];
  fields.forEach((f, i) => {
    out[f.out] = inputs[i].stringValue.js.replace(/[\r\n]+/g, ' ');
  });
  return out.join('\n');
}

// ⌘X · ⌘C · ⌘V · ⌘A · ⌘Z 는 메뉴 막대의 편집 메뉴 단축키로 동작한다.
// osascript 로 띄운 창에는 메뉴 막대가 없어 이 메뉴를 직접 붙이지 않으면 단축키 붙여넣기가 되지 않는다
function installEditMenu(app) {
  const mainMenu = $.NSMenu.alloc.init;
  const editItem = $.NSMenuItem.alloc.init;
  const editMenu = $.NSMenu.alloc.initWithTitle('편집');
  [
    ['실행 취소', 'undo:', 'z'],
    ['잘라내기', 'cut:', 'x'],
    ['복사', 'copy:', 'c'],
    ['붙여넣기', 'paste:', 'v'],
    ['모두 선택', 'selectAll:', 'a'],
  ].forEach(([title, action, key]) => {
    editMenu.addItemWithTitleActionKeyEquivalent(title, action, key);
  });
  editItem.submenu = editMenu;
  mainMenu.addItem(editItem);
  app.mainMenu = mainMenu;
}

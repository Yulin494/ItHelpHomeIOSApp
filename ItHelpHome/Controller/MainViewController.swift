//
//  MainViewController.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/23.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tbvChat: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txfMessage: UITextField!
    
    // MARK: - Proprty
    var messages: [Message] = []
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialMessages()
        Task {
            await updateUserSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - UI Setting
    func setupUI() {
        setupTbv()
        setupNav()
    }
    
    func setupNav() {
        self.navigationItem.title = "MyItHome"
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "sun.max"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(rightButtonTapped))
        self.navigationItem.rightBarButtonItem = rightButton
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .systemBlue
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        navigationBar.tintColor = .white
    }
    
    func setupTbv() {
        tbvChat.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.identifile)
        tbvChat.dataSource = self
        tbvChat.delegate = self
        tbvChat.rowHeight = UITableView.automaticDimension
        tbvChat.estimatedRowHeight = 100
        tbvChat.separatorStyle = .none
    }
    
    func loadInitialMessages() {
        messages = [
            Message(text: "你好！有什麼我可以幫忙的嗎？我可以查詢伺服器資安事件。", sender: .bot),
            Message(text: "查詢最近的資安事件", sender: .user),
            Message(text: "好的，以下是最近的資安事件：\n伺服器A發生攻擊 2024-07-26 14:30\n伺服器B發現異常訪問 2024-07-25 22:15", sender: .bot)
        ]
        
        // 重新載入資料並滾動到底部
        tbvChat.reloadData()
        scrollToBottom(animated: false)
    }
    // MARK: - IBAcion
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = txfMessage.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let userMessage = Message(text: text, sender: .user)
        messages.append(userMessage)
        
        txfMessage.text = ""
        
        Task {
            await runAgent(for: text)
        }
    }
    // MARK: - Function
    @objc func rightButtonTapped() {
        print("rightButtonTapped")
    }
    
    func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        
        let lastIndex = messages.count - 1
        let indexPath = IndexPath(row: lastIndex, section: 0)
        
        tbvChat.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
    func updateUserSession() async {
        do {
            let stateDictionary: [String: String] = ["key1": "value1", "key2": "42"]
            let requestBody = UpdateSessionRequest(state: stateDictionary)
            
            let response: UpdateSessionResponse = try await NetworkManager.shared.requestData(method: .post,
                                                                                              server: .adk,
                                                                                              path: .session,
                                                                                              parameters: requestBody)
        } catch {
            let errorMessage = Message(text: "更新使用者狀態失敗：\(error.localizedDescription)", sender: .bot)
            messages.append(errorMessage)
            tbvChat.reloadData()
//            scrollToBottom(animated: true)
        }
    }
    
    func runAgent(for text: String) async {
        do {
            let messagePart = MessagePart(text: text)
            let messagePayload = MessagePayload(role: "user", parts: [messagePart])
            let requestBody = SendMessageRequest(appName: "multi_tool_agent",
                                                 userId: "u_123",
                                                 sessionId: "s_123",
                                                 newMessage: messagePayload)
            
            // 使用您的 NetworkManager 發送請求
            let response: SendMessageResponse = try await NetworkManager.shared.requestData(
                method: .post,
                server: .adk,
                path: .run,
                parameters: requestBody
            )
            
            // 從回應陣列中找出我們需要的最終答案
            var botText = "抱歉，我無法處理您的請求。" // 預設訊息
            if let finalAnswer = response.last(where: { $0.content.parts.first?.text != nil }) {
                botText = finalAnswer.content.parts.first?.text ?? botText
            }
            
            // 將 Bot 的回覆顯示在畫面上
            let botMessage = Message(text: botText, sender: .bot)
            messages.append(botMessage)
            tbvChat.reloadData()
//            scrollToBottom(animated: true)
        } catch {
            print("❌ Failed to fetch bot response: \(error)")
            let errorMessage = Message(text: "獲取回覆失敗: \(error.localizedDescription)", sender: .bot)
            messages.append(errorMessage)
            tbvChat.reloadData()
//            scrollToBottom(animated: true)
        }
    }
}
// MARK: - Extexsions
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifile, for: indexPath) as? MainTableViewCell else {
            // 如果還是出錯，強制崩潰並給出明確提示，方便除錯
            fatalError("無法建立 MainTableViewCell，請檢查：1. Identifier是否一致 2. XIB中的Custom Class是否設定正確")
        }
        
        let message = messages[indexPath.row]
        
        cell.configure(with: message)
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

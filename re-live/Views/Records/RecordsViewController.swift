////
////  RecordListViewController.swift
////  re-live
////
////  Created by Suzie Kim on 6/5/25.
////
//
//  RecordListViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit

final class RecordsViewController: UITableViewController {
    private var allResults: [HealthScanResult] {
        LocalStorageService.shared.loadAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recent Records"

        // ✨ 자동 셀 높이
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150

        // ✨ 스와이프 삭제 지원 셀 등록
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CardCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allResults.count
    }

    override func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        // 최신순
        let result = allResults.reversed()[indexPath.row]

        // 기본 셀로 받아온 뒤, 이전 카드 뷰 제거
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // 기존 makeRecordCard 로 카드 뷰 생성
        let card = makeRecordCard(from: result)

        // 카드가 Auto Layout 되려면 translatesAutoresizingMask… = false 되어 있어야 합니다.
        cell.contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
        ])

        return cell
    }

    // MARK: - Swipe to Delete

    override func tableView(
      _ tableView: UITableView,
      trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
            let result = self.allResults.reversed()[indexPath.row]
            LocalStorageService.shared.delete(id: result.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    // MARK: - Select to Edit

    override func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = allResults.reversed()[indexPath.row]
        let editVC = EditResultViewController(mode: .update(existing: result))
        navigationController?.pushViewController(editVC, animated: true)
    }

    // MARK: - 기존 카드 빌더(조금만 손봤습니다)

    private func makeRecordCard(from result: HealthScanResult) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        container.addGestureRecognizer(tap)
        container.tag = allResults.firstIndex(where: { $0.id == result.id }) ?? 0

        // — 제목 및 날짜
        let titleLabel = UILabel()
        titleLabel.text = "Annual Check-up"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label

        let subLabel = UILabel()
        let dateText   = result.testDate   ?? "날짜 정보 없음"
        let doctorText = result.doctorName ?? "-"
        subLabel.text = "\(dateText) • \(doctorText)"
        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel   // 회색

        let vStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        vStack.axis = .vertical
        vStack.spacing = 4

        // — 아이콘
        let icon = UIImageView(image: UIImage(systemName: "doc.text"))
        icon.tintColor = .white
        icon.backgroundColor = .systemBlue
        icon.layer.cornerRadius = 20
        icon.clipsToBounds = true
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40)
        ])

        let topRow = UIStackView(arrangedSubviews: [vStack, icon])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing

        // — 태그 (최대 2개)
        let tagStack = UIStackView()
        tagStack.axis = .horizontal
        tagStack.spacing = 8
        for item in result.testItems.prefix(3) {
            let badge = PaddingLabel()
            badge.text = "\(item.name): \(item.value) \(item.unit ?? "")"
            badge.font = .systemFont(ofSize: 12, weight: .medium)
            badge.textColor = .white
            badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            badge.layer.cornerRadius = 12
            badge.clipsToBounds = true
            badge.insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            tagStack.addArrangedSubview(badge)
        }

        // — 전체 스택
        let cardStack = UIStackView(arrangedSubviews: [topRow, tagStack])
        cardStack.axis = .vertical
        cardStack.spacing = 16
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            cardStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            cardStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])

        return container
    }

    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        let selectedResult = allResults[index]
        let detailVC = RecordDetailViewController(result: selectedResult)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

//// — LocalStorageService 에 delete(id:) 추가해주세요.
//extension LocalStorageService {
//    func delete(id: UUID) {
//        var arr = loadAll()
//        if let i = arr.firstIndex(where: { $0.id == id }) {
//            arr.remove(at: i)
//            saveAll(arr)
//        }
//    }
//    private func saveAll(_ results: [HealthScanResult]) {
//        if let d = try? JSONEncoder().encode(results) {
//            UserDefaults.standard.set(d, forKey: key)
//        }
//    }
//}

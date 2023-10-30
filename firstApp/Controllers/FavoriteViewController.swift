//
//  FavoriteViewController.swift
//  firstApp
//
//  Created by Paul James on 31.10.2023.
//

import UIKit
import RealmSwift
import AVFoundation
import MediaPlayer

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playbackImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var favoriteItems: Results<RealmModel>!
    let localRealm = try! Realm()
    
    var activeCellIndex: Int = 0
    var currentTrackIndex: Int = 0
    var isPlay = false
    var player: AVAudioPlayer!
    
    private let noFavoriteLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite items. Add your favorite sound on main view"
        label.textColor = .black
        label.font = UIFont(name: "Helvetica-bold", size: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        setupAdditionalElement()
        
        favoriteItems = localRealm.objects(RealmModel.self).filter("isFavorite == true")
        
        setupStartPlaybackControl()
        hasAnyTask()
        
        //логика управления воспроизведением в фоновом режиме
        configureAudioSession()
        setupRemoteTransportControl()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
    }
    
    private func setupAdditionalElement() {
        view.addSubview(noFavoriteLabel)
        setConstraint()
    }
    private func setConstraint() {
        NSLayoutConstraint.activate([
            noFavoriteLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            noFavoriteLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            noFavoriteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noFavoriteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])
    }
    private func hasAnyTask() {
        if favoriteItems?.count == 0 {
               tableView.isHidden = true
               noFavoriteLabel.isHidden = false
           } else {
               tableView.isHidden = false
               noFavoriteLabel.isHidden = true
               tableView.reloadData()
           }
       }
    
    private func setupStartPlaybackControl() {
        //настройка нижней панели управления
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.isEnabled = false
        
        trackNameLabel.font = UIFont(name: "Helvetica-bold", size: 17)
        trackNameLabel.text = "Select sound"
        trackNameLabel.textAlignment = .center
        trackNameLabel.textColor = .white
        
        //настройка картинки
        playbackImageView.contentMode = .scaleAspectFill
        playbackImageView.layer.cornerRadius = 8
        playbackImageView.layer.borderWidth = 2
        playbackImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playbackImageView.image = UIImage(named: "shine")
        
        bottomView.layer.cornerRadius = 8        
    }
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        if player.isPlaying {
            player.stop()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    //MARK: - Настройка проигрывателя в фоновом режиме
    //помогает управлять воспроизведением при заблокированном телефоне
    func setupRemoteTransportControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if player.isPlaying == false {
                player.play()
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if player.isPlaying == true {
                player.pause()
            }
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            self.playNextTrack()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            self.playPreviousTrack()
            return .success
        }
    }
    
    func configureNowPlayingInfo(index: Int) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = favoriteItems[index].name
        if let image = UIImage(named: favoriteItems[index].image) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in
                return image
            })
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playNextTrack() {
        if currentTrackIndex < favoriteItems.count - 1 {
            currentTrackIndex += 1
        } else {
            currentTrackIndex = 0
        }
        playTrack(at: currentTrackIndex)
        configureNowPlayingInfo(index: currentTrackIndex)
        setConfigPlaybackControl(index: currentTrackIndex)
    }
    
    func playPreviousTrack() {
        if currentTrackIndex > 0 {
            currentTrackIndex -= 1
        } else {
            currentTrackIndex = favoriteItems.count - 1
        }
        playTrack(at: currentTrackIndex)
        configureNowPlayingInfo(index: currentTrackIndex)
        setConfigPlaybackControl(index: currentTrackIndex)
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session", error.localizedDescription)
        }
    }
    
    func playTrack(at index: Int) {
        let track = favoriteItems[index].sound
        guard let url = Bundle.main.url(forResource: track, withExtension: "mp3") else {
            print("some error  Invalid track URL")
            return}
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            
        } catch {
            print("Failed to play audio", error.localizedDescription)
        }
    }
    
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavoriteTableViewCell
        
        if let item = favoriteItems?[indexPath.row] {
            
            cell.setConfiguration(model: item)
            
            cell.logicFavoriteButton()
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapper(_:)), for: .touchUpInside)
            
            //настройка показа картинки колонки в ячейке
            let indexActive = indexPath.row
            if indexActive == activeCellIndex, isPlay == true {
                cell.speakerImageView.isHidden = false
                isPlay = false
            } else {
                cell.speakerImageView.isHidden = true
                isPlay = true
            }
        }
        return cell
    }
    
    @objc func favoriteButtonTapper(_ sender: UIButton){
        if let item = favoriteItems?[sender.tag] {
            try! localRealm.write {
                item.isFavorite = !item.isFavorite
            }
            hasAnyTask()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    //MARK: настройка аудиовоспроизведения
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        currentTrackIndex = indexPath.row
        playTrack(at: currentTrackIndex)
        
        animatePlaybackImageView()
        setConfigPlaybackControl(index: currentTrackIndex)
        configureNowPlayingInfo(index: currentTrackIndex)
        
        tableView.reloadData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    //при воспроизведении трека у нас в нижнем блоке появляется тайтл трека
    func setConfigPlaybackControl(index: Int) {
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButton.isEnabled = true
        //тут мы просто присваиваем индекс активной ячейке переменной
        activeCellIndex = index
        
        trackNameLabel.text = favoriteItems[index].name
        playbackImageView.image = UIImage(named: favoriteItems[index].image)
        
        tableView.reloadData()
        
    }
    
    func animatePlaybackImageView() {
        UIView.animate(withDuration: 0.2) {
            self.playbackImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.playbackImageView.transform = CGAffineTransform.identity

            }
        }
    }
}

extension FavoriteViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playNextTrack()
    }
}

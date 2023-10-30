//
//  ViewController.swift
//  firstApp
//
//  Created by Paul James on 30.10.2023.
//

import UIKit
import RealmSwift
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var playbackImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var items: Results<RealmModel>!
    let animalNames = [
                        //rain
                        SoundModel(titleOfRow: .cityRain, imageOfRow: .cityRain, soundOfRow: .cityRain),
                       SoundModel(titleOfRow: .forestRain, imageOfRow: .forestRain, soundOfRow: .forestRain),
                       SoundModel(titleOfRow: .heavyRain, imageOfRow: .heavyRain, soundOfRow: .heavyRain),
                       SoundModel(titleOfRow: .rainOnAnUmbrella, imageOfRow: .rainOnAnUmbrella, soundOfRow: .rainOnAnUmbrella),
                       SoundModel(titleOfRow: .rainOnTheWindow, imageOfRow: .rainOnTheWindow, soundOfRow: .rainOnTheWindow),
                       SoundModel(titleOfRow: .springRainWithThunder, imageOfRow: .springRainWithThunder, soundOfRow: .springRainWithThunder),
                       SoundModel(titleOfRow: .thunderstorm, imageOfRow: .thunderstorm, soundOfRow: .thunderstorm),
                        //winter
                       SoundModel(titleOfRow: .footstepsInTheSnow, imageOfRow: .footstepsInTheSnow, soundOfRow: .footstepsInTheSnow),
                       SoundModel(titleOfRow: .blizzard, imageOfRow: .blizzard, soundOfRow: .blizzard),
                        SoundModel(titleOfRow: .blizzard2, imageOfRow: .blizzard2, soundOfRow: .blizzard2),
                        
                        //wind
                        SoundModel(titleOfRow: .windOnMount, imageOfRow: .windOnMount, soundOfRow: .windOnMount),
                        SoundModel(titleOfRow: .windOnGrass, imageOfRow: .windOnGrass, soundOfRow: .windOnGrass),
                        SoundModel(titleOfRow: .leavesOnWind, imageOfRow: .leavesOnWind, soundOfRow: .leavesOnWind),
                        SoundModel(titleOfRow: .hurricane, imageOfRow: .hurricane, soundOfRow: .hurricane),
                        
                        //water
                        SoundModel(titleOfRow: .oceanWaves, imageOfRow: .oceanWaves, soundOfRow: .oceanWaves),
                        SoundModel(titleOfRow: .rainAndSea, imageOfRow: .rainAndSea, soundOfRow: .rainAndSea),
                        SoundModel(titleOfRow: .waterfall, imageOfRow: .waterfall, soundOfRow: .waterfall),
                        SoundModel(titleOfRow: .wavesAndRocks, imageOfRow: .wavesAndRocks, soundOfRow: .wavesAndRocks),
                        
                        //nature
                        SoundModel(titleOfRow: .bonfire, imageOfRow: .bonfire, soundOfRow: .bonfire),
                        SoundModel(titleOfRow: .village, imageOfRow: .village, soundOfRow: .village),
                        
                        
                        //emptyness
                      
    ]
    let localRealm = try! Realm()
    var activeCellIndex: Int = 0
    var currentTrackIndex: Int = 0
    var isPlay = true
    var player: AVAudioPlayer!
    var timer: Timer?
    //для таймера
    var countDownTimer: Timer?
    var totalTimeInSeconds: Int = 0
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
         
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Pacific sound", style: .plain, target: nil, action: nil) //убрать слово "back" из навигейшена
        navigationController?.navigationBar.tintColor = .white //изменение цвета backButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        setupTableView()
        
        addItemsInRealmModel()
        
        items = localRealm.objects(RealmModel.self)
        
        setupStartPlaybackControl()
        
        //логика управления воспроизведением в фоновом режиме
        configureAudioSession()
        setupRemoteTransportControl()
        
        //для таймера
        resetTimer()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    private func addItemsInRealmModel() {
        //добавляю значения в массив items
        
        for animalName in animalNames {
            let animal = animalName.titleOfRow.rawValue
            let animalIMage = animalName.imageOfRow.rawValue
            let animalSound = animalName.soundOfRow.rawValue
            if localRealm.objects(RealmModel.self).filter("name == %@", animal).first == nil{
                let item = RealmModel()
                item.name = animal
                item.image = animalIMage
                item.sound = animalSound
                RealmManager.shared.saveModel(model: item)
            }
        }
    }
    
    //MARK: - подготовка панели воспроизведения
    private func setupStartPlaybackControl() {
        //настройка нижней панели управления
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.isEnabled = false
        timerButton.isEnabled = false
        
        trackNameLabel.font = UIFont(name: "Helvetica-bold", size: 17)
        trackNameLabel.text = "Select sound"
        trackNameLabel.textAlignment = .center
        
        //настройка картинки
        playbackImageView.contentMode = .scaleAspectFill
        playbackImageView.layer.cornerRadius = 8
        playbackImageView.layer.borderWidth = 2
        playbackImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playbackImageView.image = UIImage(named: "shine")
        
        bottomView.layer.cornerRadius = 8
        
        
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if player.isPlaying {
            player.stop()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    //MARK: - настройка таймера
    @IBAction func timerButtonTapped(_ sender: UIButton) {
        let sliderVC = storyboard?.instantiateViewController(withIdentifier: "slider") as! TimerViewController
        
        sliderVC.remainingTime = totalTimeInSeconds
        sliderVC.onSelection = { [weak self] selectedMinutes in
            guard let self = self else {return}
                self.totalTimeInSeconds = selectedMinutes * 60
                self.updateUI()
                self.startTimer()
            
        }
        //попытка открыть вью контроллер на половину экрана
        if let presentationController = sliderVC.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
        }
    
        present(sliderVC, animated: true)
    }
    
    func startTimer() {
        stopTimer()
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if totalTimeInSeconds > 0 {
            totalTimeInSeconds -= 1
            updateUI()
        } else {
            stopTimer()
            stopMusicWithStopTimer()
        }
    }
    
    func stopTimer() {
        countDownTimer?.invalidate()
        
    }
    
    func stopMusicWithStopTimer() {
        player.stop()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func updateUI() {
//        let minutes = totalTimeInSeconds / 60
//        let seconds = totalTimeInSeconds % 60
//        timeLabel.text = String(format: "%02d : %02d", minutes, seconds)
    }
    
    func resetTimer() {
        countDownTimer?.invalidate()
        totalTimeInSeconds = 0
        updateUI()
    }
    
    
    //MARK: - Настройка проигрывателя в фоновом режиме
    
    //помогает управлять воспроизведением при заблокированном телефоне
    func setupRemoteTransportControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if player.isPlaying == false {
                player.play()
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if player.isPlaying == true {
                player.pause()
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
        nowPlayingInfo[MPMediaItemPropertyTitle] = items[index].name
        if let image = UIImage(named: items[index].image) {
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
        if currentTrackIndex < items.count - 1 {
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
            currentTrackIndex = items.count - 1
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
        let track = items[index].sound
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
    
    //MARK: - Настройка таймера и алерта
    
    
}
//MARK: - TableView methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let item = items[indexPath.row]
        
        if indexPath.row == items.count {
            cell.setSpectialConfig(text: "SMTH")
        } else {
            cell.setConfiguration(model: item)
        }
        
        
        
        //настройка работы кнопки избранное
        cell.logicFavoriteButton()
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtontapped(_:)), for: .touchUpInside)
        
        //настройка показа картинки колонки в ячейке
        let indexActive = indexPath.row
        if indexActive == activeCellIndex, isPlay == false {
            cell.speakerImageView.isHidden = false
            cell.favoriteButton.isHidden = false
            isPlay = true
        } else {
            cell.speakerImageView.isHidden = true
            cell.favoriteButton.isHidden = true
            isPlay = false
        }
        
        return cell
    }
    
    @objc func favoriteButtontapped(_ sender: UIButton) {
        if let item = items?[sender.tag] {
            try! localRealm.write {
                item.isFavorite = !item.isFavorite
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editingRow = items?[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            RealmManager.shared.deleteModel(model: editingRow!)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    //MARK: настройка аудиовоспроизведения
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //        let trackName = items[indexPath.row].sound
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
        timerButton.isEnabled = true
        //тут мы просто присваиваем индекс активной ячейке переменной
        activeCellIndex = index
        
        trackNameLabel.text = items[index].name
        playbackImageView.image = UIImage(named: items[index].image)
        
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

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playNextTrack()
    }
}

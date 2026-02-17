import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/story.dart';

class EbookReaderScreen extends StatefulWidget {
  final Story story;

  const EbookReaderScreen({
    super.key,
    required this.story,
  });

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends State<EbookReaderScreen> {
  double _fontSize = 16.0;
  bool _isNightMode = false;
  final List<int> _bookmarks = [];
  int _currentPage = 1;
  final int _totalPages = 45;
  
  // Sample text content
  final String _sampleContent = '''
Hapo zamani, katika porini kubwa la Afrika, kulikuwa na simba mjanja aliyeitwa Tau. Tau alikuwa na hekima nyingi na wanyama wengine walimpenda sana.

Siku moja, mvua kali ilinyesha na mto mkubwa ulipinda na kuingia porini. Wanyama wote walikuwa na wasiwasi kuhusu mahali pa salama.

Tau aliwakusanya wanyama wote na kuwaambia, "Haikubaliki tuwe na hofu. Tunapaswa kuwa na ujasiri na kufanya kazi pamoja ili kupata ufumbuzi."

Wanyama walisikiliza kwa makini. Twiga alitazama juu na kuona milima ya mbali. "Hapo ni salama," alisema. Lakini njia ilikuwa ndefu na hatari.

Tau aliweka mpango. Tembo wakaongoza njia kwa nguvu zao, nyani wakasaidia watoto, na ndege wakapigapiga mbawa zao kwa ishara za maelekezo.

Baada ya safari ndefu, wote walifika salama kwa kilima. Wanyama wote walishangilia na kumshukuru Tau kwa uongozi wake.

Kutoka siku hiyo, wanyama walijifunza kwamba kwa pamoja, wanaweza kushinda changamoto yoyote. Na Tau, simba mjanja, alibaki kuwa kiongozi mwenye hekima na moyo wa huruma.

Mwisho.
  ''';

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isNightMode ? const Color(0xFF1a1a1a) : AppColors.backgroundLight;
    final textColor = _isNightMode ? const Color(0xFFe0e0e0) : AppColors.textPrimary;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _isNightMode ? const Color(0xFF252525) : AppColors.cardBackground,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.story.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Ukurasa $_currentPage wa $_totalPages',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isNightMode ? Colors.grey[400] : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _bookmarks.contains(_currentPage) ? Icons.bookmark : Icons.bookmark_border,
                      color: _bookmarks.contains(_currentPage) ? AppColors.sunsetOrange : textColor,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ],
              ),
            ),
            
            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _sampleContent,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.8,
                    color: textColor,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ),
            
            // Bottom controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _isNightMode ? const Color(0xFF252525) : AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress slider
                  Row(
                    children: [
                      Text(
                        '$_currentPage',
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentPage.toDouble(),
                          min: 1,
                          max: _totalPages.toDouble(),
                          divisions: _totalPages - 1,
                          activeColor: AppColors.sunsetOrange,
                          inactiveColor: _isNightMode ? Colors.grey[700] : AppColors.textMuted.withOpacity(0.2),
                          onChanged: (value) {
                            setState(() {
                              _currentPage = value.round();
                            });
                          },
                        ),
                      ),
                      Text(
                        '$_totalPages',
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlItem(
                        icon: Icons.text_decrease,
                        label: 'Punguza',
                        onTap: _decreaseFontSize,
                        color: textColor,
                      ),
                      _buildControlItem(
                        icon: Icons.text_increase,
                        label: 'Ongeza',
                        onTap: _increaseFontSize,
                        color: textColor,
                      ),
                      _buildControlItem(
                        icon: _isNightMode ? Icons.light_mode : Icons.dark_mode,
                        label: _isNightMode ? 'Mchana' : 'Usiku',
                        onTap: _toggleNightMode,
                        color: textColor,
                      ),
                      _buildControlItem(
                        icon: Icons.bookmarks,
                        label: 'Alamisho (${_bookmarks.length})',
                        onTap: _showBookmarks,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _increaseFontSize() {
    if (_fontSize < 28) {
      setState(() {
        _fontSize += 2;
      });
    }
  }
  
  void _decreaseFontSize() {
    if (_fontSize > 12) {
      setState(() {
        _fontSize -= 2;
      });
    }
  }
  
  void _toggleNightMode() {
    setState(() {
      _isNightMode = !_isNightMode;
    });
  }
  
  void _toggleBookmark() {
    setState(() {
      if (_bookmarks.contains(_currentPage)) {
        _bookmarks.remove(_currentPage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alama imefutwa'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        _bookmarks.add(_currentPage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukurasa umewekwa alama'),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }
  
  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isNightMode ? const Color(0xFF252525) : AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final textColor = _isNightMode ? const Color(0xFFe0e0e0) : AppColors.textPrimary;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alamisho Zako',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              if (_bookmarks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Huna alamisho bado',
                      style: TextStyle(
                        color: _isNightMode ? Colors.grey[400] : AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...(_bookmarks..sort()).map((page) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark, color: AppColors.sunsetOrange, size: 20),
                  title: Text(
                    'Ukurasa $page',
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: textColor, size: 20),
                    onPressed: () {
                      setState(() {
                        _bookmarks.remove(page);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _currentPage = page;
                    });
                    Navigator.pop(context);
                  },
                )),
            ],
          ),
        );
      },
    );
  }
}

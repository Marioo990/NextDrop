import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/event_validator.dart';
import '../../../domain/entities/event.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';
import '../../widgets/event_image_widget.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  final int? eventId;

  const EventFormScreen({super.key, this.eventId});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _publisherController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  TimeOfDay? _startTime;
  EventType _type = EventType.series;
  String _category = AppConstants.defaultCategories.first;
  String _platform = AppConstants.defaultPlatforms.first;
  Recurrence _recurrence = Recurrence.weekly;
  int? _recurrenceInterval;
  WeekDay? _recurrenceDay;
  int? _batchSize;
  String? _imagePath;
  bool _notificationsEnabled = true;
  int? _notificationMinutes;
  int? _totalEpisodes;
  EventStatus _status = EventStatus.upcoming;
  int? _rating;
  bool _isLoading = false;

  Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEvent();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settings = ref.read(settingsProvider);
        setState(() {
          _notificationMinutes = settings.defaultNotificationMinutes;
        });
      });
    }
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    final event = await ref.read(eventRepositoryProvider).getEventById(widget.eventId!);

    if (event != null && mounted) {
      setState(() {
        _titleController.text = event.title;
        _publisherController.text = event.publisher ?? '';
        _descriptionController.text = event.description ?? '';
        _noteController.text = event.userNote ?? '';
        _startDate = event.startDate;
        _endDate = event.endDate;
        _startTime = event.startTime;
        _type = event.type;
        _category = event.category;
        _platform = event.platform;
        _recurrence = event.recurrence;
        _recurrenceInterval = event.recurrenceInterval;
        _recurrenceDay = event.recurrenceDay;
        _batchSize = event.batchSize;
        _imagePath = event.imagePath;
        _notificationsEnabled = event.notificationsEnabled;
        _notificationMinutes = event.notificationMinutes;
        _totalEpisodes = event.totalEpisodes;
        _status = event.status;
        _rating = event.rating;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _publisherController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validateBeforeSave() {
    final tempEvent = _buildEventFromForm();
    final errors = EventValidator.validateEvent(tempEvent);

    setState(() {
      _validationErrors = errors;
    });
  }

  Event _buildEventFromForm() {
    final now = DateTime.now();
    return Event(
      id: widget.eventId,
      title: _titleController.text,
      startDate: _startDate,
      startTime: _startTime,
      endDate: _endDate,
      recurrence: _recurrence,
      recurrenceInterval: _recurrenceInterval,
      recurrenceDay: _recurrenceDay,
      batchSize: _batchSize,
      type: _type,
      category: _category,
      platform: _platform,
      imagePath: _imagePath,
      publisher: _publisherController.text.isNotEmpty ? _publisherController.text : null,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      userNote: _noteController.text.isNotEmpty ? _noteController.text : null,
      notificationsEnabled: _notificationsEnabled,
      notificationMinutes: _notificationMinutes,
      totalEpisodes: _totalEpisodes,
      status: _status,
      rating: _rating,
      createdAt: widget.eventId == null ? now : now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null
            ? S.of(context).addEvent
            : S.of(context).editEvent),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEvent,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_validationErrors.isNotEmpty) _buildValidationWarning(),
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildScheduleSection(),
            const SizedBox(height: 24),
            _buildDetailsSection(),
            const SizedBox(height: 24),
            _buildNotificationsSection(),
            const SizedBox(height: 32),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'Validation errors:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._validationErrors.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Text(
              '• ${entry.value}',
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: EventImageWidgetWithHero(
        imagePath: _imagePath,
        width: 150,
        height: 200,
        isEditable: true,
        onTap: _pickImage,
        heroTag: widget.eventId != null ? 'event_image_${widget.eventId}' : null,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).eventTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: '${S.of(context).eventTitle} *',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return S.of(context).eventTitle;
            }
            if (value.trim().length < 2) {
              return 'Min 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _publisherController,
          decoration: InputDecoration(
            labelText: S.of(context).eventPlatform,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<EventType>(
          value: _type,
          decoration: InputDecoration(
            labelText: S.of(context).eventType,
            border: const OutlineInputBorder(),
          ),
          items: EventType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _type = value);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
            labelText: S.of(context).eventCategory,
            border: const OutlineInputBorder(),
          ),
          items: AppConstants.defaultCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _category = value);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _platform,
          decoration: InputDecoration(
            labelText: S.of(context).eventPlatform,
            border: const OutlineInputBorder(),
          ),
          items: AppConstants.defaultPlatforms.map((platform) {
            return DropdownMenuItem(
              value: platform,
              child: Text(platform),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _platform = value);
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Start Date'),
          subtitle: Text(DateFormat('dd.MM.yyyy').format(_startDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickStartDate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Time'),
          subtitle: Text(_startTime != null ? _startTime!.format(context) : 'Not set'),
          trailing: const Icon(Icons.access_time),
          onTap: _pickStartTime,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<EventStatus>(
          value: _status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: EventStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _status = value);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Recurrence>(
          value: _recurrence,
          decoration: const InputDecoration(
            labelText: 'Recurrence',
            border: OutlineInputBorder(),
          ),
          items: Recurrence.values.map((recurrence) {
            return DropdownMenuItem(
              value: recurrence,
              child: Text(recurrence.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _recurrence = value);
            }
          },
        ),
        if (_recurrence == Recurrence.custom) ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Interval (days)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            initialValue: _recurrenceInterval?.toString(),
            onChanged: (value) {
              setState(() => _recurrenceInterval = int.tryParse(value));
            },
          ),
        ],
        if (_recurrence == Recurrence.weekly) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<WeekDay>(
            value: _recurrenceDay,
            decoration: const InputDecoration(
              labelText: 'Day of week',
              border: OutlineInputBorder(),
            ),
            items: WeekDay.values.map((day) {
              return DropdownMenuItem(
                value: day,
                child: Text(day.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _recurrenceDay = value);
            },
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _totalEpisodes == null
                    ? 'none'
                    : (_totalEpisodes == 12 || _totalEpisodes == 24)
                    ? _totalEpisodes.toString()
                    : 'custom',
                decoration: InputDecoration(
                  labelText: S.of(context).episodes,
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Not specified')),
                  DropdownMenuItem(value: '12', child: Text('12 episodes')),
                  DropdownMenuItem(value: '24', child: Text('24 episodes')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom...')),
                ],
                onChanged: (value) {
                  if (value == 'custom') {
                    _showCustomEpisodeDialog();
                  } else if (value == 'none') {
                    setState(() => _totalEpisodes = null);
                  } else {
                    setState(() => _totalEpisodes = int.parse(value!));
                  }
                },
              ),
            ),
            if (_totalEpisodes != null && _totalEpisodes! > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Chip(
                  label: Text('$_totalEpisodes ep.'),
                  onDeleted: () {
                    setState(() => _totalEpisodes = null);
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).eventDescription,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: S.of(context).eventDescription,
            border: const OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).notifications,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: Text(S.of(context).notifications),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
        ),
        if (_notificationsEnabled) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _notificationMinutes,
            decoration: InputDecoration(
              labelText: S.of(context).notifications,
              border: const OutlineInputBorder(),
              errorText: _validationErrors['notification'],
            ),
            items: const [
              DropdownMenuItem(value: 15, child: Text('15 min before')),
              DropdownMenuItem(value: 30, child: Text('30 min before')),
              DropdownMenuItem(value: 60, child: Text('1 hour before')),
              DropdownMenuItem(value: 120, child: Text('2 hours before')),
              DropdownMenuItem(value: 1440, child: Text('1 day before')),
              DropdownMenuItem(value: 2880, child: Text('2 days before')),
            ],
            onChanged: (value) {
              setState(() => _notificationMinutes = value);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(S.of(context).cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                S.of(context).save,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() => _imagePath = pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        _status = EventValidator.suggestStatus(_startDate, _endDate);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _showCustomEpisodeDialog() async {
    final controller = TextEditingController(
      text: _totalEpisodes != null && _totalEpisodes! > 24 ? _totalEpisodes.toString() : '',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).episodes),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Episodes (1-500)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value < 1000) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter 1-999')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _totalEpisodes = result);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).eventSaved)),
      );
      return;
    }

    _validateBeforeSave();

    final event = _buildEventFromForm();

    if (_validationErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${_validationErrors.length} errors'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      int? savedEventId;

      if (widget.eventId == null) {
        savedEventId = await ref.read(eventRepositoryProvider).createEvent(event);
      } else {
        await ref.read(eventRepositoryProvider).updateEvent(event);
        savedEventId = widget.eventId;
      }

      if (_totalEpisodes != null && _totalEpisodes! > 0 && savedEventId != null) {
        int intervalDays = 7;

        switch (_recurrence) {
          case Recurrence.daily:
            intervalDays = 1;
            break;
          case Recurrence.weekly:
            intervalDays = 7;
            break;
          case Recurrence.biweekly:
            intervalDays = 14;
            break;
          case Recurrence.monthly:
            intervalDays = 30;
            break;
          case Recurrence.custom:
            intervalDays = _recurrenceInterval ?? 7;
            break;
          case Recurrence.batch:
            intervalDays = _recurrenceInterval ?? 7;
            break;
          case Recurrence.once:
            intervalDays = 0;
            break;
        }

        await ref.read(episodeRepositoryProvider).generateEpisodes(
          savedEventId,
          _startDate,
          _totalEpisodes!,
          intervalDays,
          _startTime,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).eventSaved),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
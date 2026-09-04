import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geotracker/src/dependencies_config.dart';
import 'package:geotracker/src/domain/track.dart';
import 'package:geotracker/src/features/details/presentation/details_page.dart';
import 'package:geotracker/src/ui/formatters/track_formatters.dart';
import 'package:geotracker/src/ui/widgets/widgets_export.dart';

import 'history_cubit.dart';
import 'history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => container<HistoryCubit>(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История маршрутов')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          return state.when(
            initial: () => const InitializationWidget(),
            loading: () => const InitializationWidget(),
            error: (error) => LoadingErrorWidget(
              errorText: error.toString(),
              buttonText: 'Повторить',
              callback: () => context.read<HistoryCubit>().load(),
            ),
            loaded: (tracks) {
              if (tracks.isEmpty) {
                return const Center(
                  child: Text('Пока нет сохранённых маршрутов'),
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<HistoryCubit>().load(),
                child: ListView.separated(
                  itemCount: tracks.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _TrackListTile(track: track);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TrackListTile extends StatelessWidget {
  const _TrackListTile({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final avgKmh = TrackFormatters.mpsToKmh(track.averageSpeedMps);

    return ListTile(
      title: Text(track.name),
      subtitle: Text(
        '${TrackFormatters.formatDistanceKm(track.distanceMeters)} · '
        '${TrackFormatters.formatDurationHms(track.duration)} · '
        '${TrackFormatters.formatSpeedKmh(avgKmh)}',
      ),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailsPage(trackId: track.id),
          ),
        );
        if (context.mounted) {
          await context.read<HistoryCubit>().load();
        }
      },
      trailing: PopupMenuButton<_TrackAction>(
        onSelected: (action) => _onAction(context, action),
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _TrackAction.rename,
            child: Text('Переименовать'),
          ),
          PopupMenuItem(
            value: _TrackAction.delete,
            child: Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext context, _TrackAction action) async {
    final cubit = context.read<HistoryCubit>();
    switch (action) {
      case _TrackAction.rename:
        final name = await _showRenameDialog(context, track.name);
        if (name != null) {
          await cubit.rename(track.id, name);
        }
      case _TrackAction.delete:
        final confirmed = await _showDeleteDialog(context, track.name);
        if (confirmed == true) {
          await cubit.delete(track.id);
        }
    }
  }

  Future<String?> _showRenameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Переименовать маршрут'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить маршрут?'),
          content: Text('«$name» будет удалён без возможности восстановления.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
}

enum _TrackAction { rename, delete }
